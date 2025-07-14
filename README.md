# Candidate-Events-MP-Website-Scrape

DISCLAIMER: Where as the Application code script and tool is intended to facilitate research, by authorised and approved parties, pursuant to the ideals of libertarian democracy in the UK, by Campaign Lab membership. And where as deemed to be in the public domain, content subject-matter and generated results can be assumed sensitive and thus confidential. Therefore illicit and unauthorised usage outside these terms, is hereby not implied pursuant to requisite UK Data Protection legislation and the wider GDPR enactments within the EU. Usage without the consent of the author, is also NOT implied.

BACKGROUND: How political candidates and politicians describe themselves and how they choose to spend their time are both enormously rich data points that can allow us to cut through the noise and understand what the people running our country actually think, what their priorities really are. 

CHALLENGE: Scrape the text and events pages of MPs websites and create a navigable database containing that information so that it can be subject to analysis. 

FOUNDATION AND PRIMARY SOLUTION:

Here is a complete Scrapy project written in a single Python file that:

I. Creates a Scrapy project structure programmatically.
II. Crawls the two provided URLs to find MP profile pages.
III. Extracts text from those pages and any linked "events" or similar detail pages.
IV. Uses regex to identify personality traits, ideologies, etc. from the text.
V. Stores the data in a JSON file named ukmpprofile2.json.

Below is a visual representation of the Scrapy workflow tailored to your ukmpprofile2_project, which scrapes UK MP profiles and their event pages:

---

🕸️ Scrapy Workflow for ukmpprofile2_project

graph TD
    A[Start: run_ukmpprofile2_scraper.py] --> B[Scrapy Engine]
    B --> C[Scheduler]
    C --> D[Downloader]
    D --> E[Spider: UKMPProfileSpider]
    E --> F[Parse start URLs]
    F --> G{Identify MP Profile Links}
    G -->|TheyWorkForYou| H[parse_mp_profile_twf]
    G -->|Parliament.uk| I[parse_mp_profile_parliament]
    H --> J[Extract MP Details]
    I --> J
    J --> K[Identify Events URLs]
    K --> L[Follow Events URLs]
    L --> M[parse_event_text]
    M --> N[Extract Text Content]
    N --> O[infer_profile]
    O --> P[MPProfileItem]
    P --> Q[Item Pipeline]
    Q --> R[Export to ukmpprofile2.json]

---

🧩 Component Breakdown

Scrapy Engine: Coordinates the data flow between all components.

Scheduler: Queues up requests to be processed.

Downloader: Fetches web pages and feeds them to the engine.

Spider (UKMPProfileSpider): Contains the logic to parse the MP profiles and their event pages.

Item Pipeline: Processes the extracted data and exports it to a JSON file. 

---

📄 Output

The final output is a JSON file named ukmpprofile2.json, containing structured data about each MP's personality profile, social identity, ideological standpoint, and more. 


ADDENDA:

The Python script code offers the primary foundation to the building blocks, of a host of solutions to the defined project challenges. Additional Python libraries may be incorporated, as and when necessary, to provide alternate and enhanced programatic solutions later.

Written in UNIX/LINUX script format, the program code is compartible with MacOS CLI for execution thus; (user)$: sudo chmod u+x ukmpprofile2_jason.py. Alternatively, Microsoft Windows users can edit the UNIX/LINUX "shebang!" headers and run the script directly from the Python Directory environment, via CMD/CLI or Powershell.


----- ----- ----- ----- ------ ------- ------ ------- 


The ukmpprofile2_csv.pl code script represents a revised web scrapping Application tool written in PERL 5.x, that equally provides  requisite solutions to the stated project challenges thus;

Scrapes MP data from:

1. https://www.theyworkforyou.com/mps/

2. https://members.parliament.uk/constituencies

Visits each MP’s profile/linked page to collect and analyze textual data.

Uses regex to extract insights (e.g., personality, ideology, policy themes).

Stores results in a CSV (ukmpprofile2.csv).


Provides both:

A CLI search interface.

A Mojolicious web viewer for search/display.


------ ------ ------ ------ ------

✅ How to Use:

1. Run scraper + save CSV:

perl ukmpprofile2_csv.pl, (or $ chmod u+x ukmpprofile2_csv.pl, for UNIX/LINUX & MacOS System Plarforms)

2. CLI Search:

perl ukmpprofile2_csv.pl cli --search "NHS"

3. Run Web Viewer:

perl ukmpprofile2_csv.pl web

Then open http://localhost:3000 in your browser.


------ ------- ------ -------

✅ Operating System Dependencies:

Install required CPAN modules:

cpan install Mojo::UserAgent Mojo::DOM Text::CSV Mojolicious Getopt::Long











