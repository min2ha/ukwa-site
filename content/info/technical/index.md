## UK Web Archive Crawler Settings

We run a number of differnet web crawlers for different purposes. Our curated crawls visit hundreds of sites on a daily, weekly, monthly, quarterly or six-monthly basis. This crawl process uses two different approaches for capturing web pages. For important URLs, we use an automated web browser to download the page, including images, stylesheets, and some dynamic JavaScript content. We identify this crawling process by including the following declaration in the User Agent:

    bl.uk_lddc_renderbot/{{VERSION}} (+ http://www.bl.uk/aboutus/legaldeposit/websites/websites/faqswebmaster/index.html)

Because this runs a web browser, this process can download quite a lot of URLs in a short time, just like a normal user. However, only a very small set of URLs use this process. The vast majority of URLs are downloaded using a more traditional web crawler that works a bit more like a normal search engine web crawler. This identifies itself as:

    bl.uk_ldfc_bot/{{VERSION}} (+ http://www.bl.uk/aboutus/legaldeposit/websites/websites/faqswebmaster/index.html)

for the usual regular crawling activity, or as

    bl.uk_lddc_bot/{{VERSION}} (+ http://www.bl.uk/aboutus/legaldeposit/websites/websites/faqswebmaster/index.html)

if it's part of our less frequent domain crawls, where we attempt to download content from all UK web sites, which we usually do once per year.

These larger-scale crawls are more polite, and will download resources from a given web site at no more than two requests per second, and in general `robots.txt` is respected and is checked every hour for any changes.

We do occasionally chose to disobey `robots.txt` if necessary. Those directives are usually composed with search engines in mind, and as such, tend to block resources that are unimportant to search engines like stylesheets or JavaScript. However, as we are an archival web crawler, we need those resources, so sometimes have to ignore `robots.txt` in order to get them.

In general a limit is set on the number of URLs downloaded and the size: exceeding the limit will automatically stop the crawler. This ensures that if the crawler is in some kind of "trap" it will stop automatically when either of the limits is reached. These download caps are occasionally lifted on sites where we wish to ensure we get as much of the content as possible.

## Making Your Website Crawler-Friendly

There are a number of things which you can do to help the UK Web Archive capture as much content as possible from your website:

 * Create a Site Map page. An XML site map can also be useful. Creating a sitemap ensures all the website content can be crawled (some pages may not be discoverable by the crawler, for example pages which use Flash or JavaScript navigation).
 * Use robots.txt to prevent access to areas of the site which may cause problems if crawled e.g. databases, including online catalogues; "shopping baskets", etc.
 * Provide standard links to content which would otherwise only be accessed via selecting drop down menus, certain dynamic kinds of navigation (e.g JavaScript) or by conducting searches on the website. This is because the crawler cannot access content hidden behind search forms. Websites can of course still use those devices but if standard links are also provided on the website then the content is more likely to be captured properly.

## What Can't Yet Be Archived

The current generation of web crawlers cannot capture:

* Dynamically generated content
* Content that is only available via a search engine on the website
* Some types of JavaScript-driven menus
* YouTube videos, Flash movies and similar streaming audio or video (some audio files can, however, be captured)

Unlike static HTML, which is relatively easy to capture, script code is almost impossible for web crawlers to analyse. In practical terms this means that entering queries into the search box of an archived version of a website will not work. Standard links on the website, however, will work as normal.

Many sites provide both a search box and a site map to help their users search content in different ways, but if there is only search engine retrieval the UK Web Archive will not be able to harvest the content.

Some JavaScript driven menus do not function well once archived. YouTube videos, Flash movies, and similar streaming audio or video are also beyond the capability of web crawlers. However, as members of the International Internet Preservation Consortium, contributors to the UK Web Archive are developing tools which will help capture this content in the future.

The crawler software cannot gather any material that is protected behind a password, without the owner's collaboration. Web site owners may however choose to divulge confidentially a user ID and password to allow archiving of these areas. Please email us for more information.

## Search Engines and the UK Web Archive


The UK Web Archive site is indexed by search engines but only to the level of the information pages: search engines are not allowed to index the archived sites.

For example, if you search for the 'Arts and Humanities Research Council' on Google , you will only find the live site on the initial pages of hits. If you search for 'Archive' and the 'Arts and Humanities Research Council', you will find a UK web Archive information page which links to the archived instances of the AHRC website.

This is to stop the Archive diverting traffic from the live site and to prevent users thinking that information on the archived version is actually the latest version of events. The archived version of your website will not appear in a search engine.

## Linking to the UK Web Archive

All sites are welcome to link to the UK Web Archive.

To use a plain text link, simply copy and paste the following code below onto your page. Please customise the text between > and < to suit your own house style of citation:

    <div style=...><a href="http://www.webarchive.org.uk/">Click here for the UK Web Archive</a></div>

To use a link that has the UK Web Archive logo, then copy and paste this code:

    <div style=...><a href="http://www.webarchive.org.uk/"><img alt="UK Web Archive" src="https://www.webarchive.org.uk/en/ukwa/img/ukwa-logo-60px.jpg"></img></a></div>

## Technical Background

Websites are gathered for the UK Web Archive with the Web Curator Tool (WCT) which was developed collaboratively by the National Library of New Zealand and the British Library, under the auspices of the International Internet Preservation Consortium. WCT is an openÂ­source software, freely available under the terms of the Apache Public License. WCT manages the selective web harvesting process.

WCT allows web archivists to manage their workflows for the following core processes:

* Harvest authorisation: getting permission to harvest Web material and make it available
* Selection, scoping and scheduling: what will be harvested, how, when and how often
* Description: adding descriptive metadata
* Harvesting: downloading the material at the appointed time using the Heritrix Web harvester
* Quality Assurance (QA): making sure the harvest worked as expected, and correcting simple harvest errors.

The Web Curator Tool works in a similar way to a browser in that it makes requests of a host for files. The software follows links within a site and gathers the accessible files it finds. It is capable of gathering database driven sites such as PHP or ASP sites, but cannot however gather contents of databases Â­ the so-called "deep web" Â­ such as library catalogues.

WCT uses the Heritrix crawler software, developed by the Internet Archive, which is tuned to "polite" to minimise the impact on the websites being crawled. 
