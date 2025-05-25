#!/usr/bin/env python3

# DISCLAIMER: The Application code script and tool is intended to facilitate research, by authorised and approved parties, pursuant to the ideals of libertarian democracy in the UK, by Campaign Lab membership. Content subject-matter and results can be deemed sensitive and thus confidential. Therefore illicit and authorisation for any other use, outside these terms, is hereby not implied pursuant to requisite UK Data Protection legislation and the wider GDPR enactments within the EU.

# CODE REVISION: Ejimofor Nwoye, Campaign Lab, Newspeak House, London, England, 05/05/2025

# File: run_ukmpprofile2_scraper.py

import os
import re
import scrapy
from scrapy.crawler import CrawlerProcess
from urllib.parse import urljoin

os.system('clear')

# Define Scrapy Item
class MPProfileItem(scrapy.Item):
    name = scrapy.Field()
    constituency = scrapy.Field()
    party = scrapy.Field()
    mp_profile_url = scrapy.Field()
    events_urls = scrapy.Field()
    extracted_text = scrapy.Field()
    inferred_profile = scrapy.Field()

# Spider to scrape the data
class UKMPProfileSpider(scrapy.Spider):
    name = 'ukmpprofile2_spider'
    allowed_domains = ['theyworkforyou.com', 'members.parliament.uk']
    start_urls = [
        'https://www.theyworkforyou.com/mps/',
        'https://members.parliament.uk/constituencies'
    ]

    def parse(self, response):
        if "theyworkforyou.com" in response.url:
            # Scrape MP listing on TheyWorkForYou
            for link in response.css("div#container li a::attr(href)").getall():
                if "/mp/" in link:
                    yield response.follow(link, callback=self.parse_mp_profile_twf)
        elif "members.parliament.uk/constituencies" in response.url:
            # Scrape constituency list for MP links
            for link in response.css("a[href*='/constituency/']::attr(href)").getall():
                yield response.follow(link, callback=self.parse_constituency)

    def parse_constituency(self, response):
        mp_link = response.css("a[href*='/member/']::attr(href)").get()
        if mp_link:
            yield response.follow(mp_link, callback=self.parse_mp_profile_parliament)

    def parse_mp_profile_twf(self, response):
        item = MPProfileItem()
        item['mp_profile_url'] = response.url
        item['name'] = response.css("h1::text").get().strip()
        item['party'] = response.css(".person .affiliation::text").get(default="").strip()
        item['constituency'] = response.css(".person .constituency::text").get(default="").strip()
        # Find links to speeches/events/etc.
        events_links = response.css("a[href*='/mp/'][href*='section']::attr(href)").getall()
        item['events_urls'] = [urljoin(response.url, link) for link in events_links]
        item['extracted_text'] = ""
        item['inferred_profile'] = {}

        for url in item['events_urls']:
            yield response.follow(url, callback=self.parse_event_text, meta={'item': item})
    
    def parse_mp_profile_parliament(self, response):
        item = MPProfileItem()
        item['mp_profile_url'] = response.url
        item['name'] = response.css("h1::text").get(default="").strip()
        item['party'] = response.css("dl:contains('Party') dd::text").get(default="").strip()
        item['constituency'] = response.css("dl:contains('Constituency') dd::text").get(default="").strip()
        events_links = response.css("a[href*='Activity'], a[href*='Speech']::attr(href)").getall()
        item['events_urls'] = [urljoin(response.url, link) for link in events_links]
        item['extracted_text'] = ""
        item['inferred_profile'] = {}

        for url in item['events_urls']:
            yield response.follow(url, callback=self.parse_event_text, meta={'item': item})

    def parse_event_text(self, response):
        item = response.meta['item']
        content = " ".join(response.css("p::text, div.content::text").getall()).strip()
        item['extracted_text'] += content + "\n"
        item['inferred_profile'] = self.infer_profile(item['extracted_text'])
        yield item

    def infer_profile(self, text):
        # Example regex-based profiling
        profile = {
            "values": [],
            "ideology": [],
            "time_focus": [],
        }

        # Regex patterns
        if re.search(r"\b(climate change|net zero|sustainability)\b", text, re.IGNORECASE):
            profile["values"].append("Environmental concern")
        if re.search(r"\b(tax cuts|free market|privatization)\b", text, re.IGNORECASE):
            profile["ideology"].append("Economic liberalism")
        if re.search(r"\b(public service|welfare|redistribution)\b", text, re.IGNORECASE):
            profile["ideology"].append("Social democracy")
        if re.search(r"\b(urgent|this week|immediately)\b", text, re.IGNORECASE):
            profile["time_focus"].append("Short-term")
        if re.search(r"\b(vision|2030|future generations)\b", text, re.IGNORECASE):
            profile["time_focus"].append("Long-term")
        
        return profile

# Run the Scrapy project
if __name__ == '__main__':
    process = CrawlerProcess(settings={
        "FEEDS": {
            "ukmpprofile2.json": {"format": "json"},
        },
        "LOG_LEVEL": "INFO",
        "USER_AGENT": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
    })

    process.crawl(UKMPProfileSpider)
    process.start()




