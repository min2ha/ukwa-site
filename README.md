UKWA Site
=========

This repository contains a static-site generator intended to manage the content and translations for the static parts of the main UK Web Archive.

## Development

The folder layout follows the [usual Hugo conventions](https://gohugo.io/getting-started/directory-structure/). When editing content, the important ones are:

- `content` which contains the main text of the pages, with separate pages used to hold the content for each language.
- `layout` which builds the templates used to turn the Markdown content in to HTML. These UKWA-specific templates build upon the `hugo-bootstrap` theme templates that can be found in the `theme` folder.
- `i18n` which contains the lists of text translations for different languages, as required by the templates.
- `static` which contains static resources that are copied to the published web site as-is.
- `assets` which contains static resources that require some processing before being published, e.g. SCSS/SASS files.

When developing source files (including `main.scss` etc.), it's easiest to use Hugo's server mode, which will auto update when there are changes:

    hugo serve

This requires the extended version of Hugo, with SCSS/SASS support, which needs a fairly recent operating system version.

If there are a lot of files, Hugo's 'watch for changes' feature may mean run out of file handles, so you can disable it like this:

    hugo serve --watch=false

This will launch a service on http://localhost:1313/ which you can connect to locally or e.g. via forwarded port in VSCode.

There is also a helper script that runs `hugo serve` via Docker:

    ./docker-serve.sh

This makes it possible to run Hugo on older operating systems, and will open up the 1313 port for remote access.

Once the system is running, you can make updates like editing the main.scss and the system should immediately re-generate the CSS from the SCSS and refresh the page you are looking at.

## Editing Content

This deployment includes [NetlifyCMS](https://www.netlifycms.org/), which is an in-browser content management system that works by being integrated with GitHub. This means GitHub can be use to manage users and authorisation, and everything is kept transparent as all changes are recorded and version controlled.

The `static/admin/config.yaml` file contains the configuration for the CMS, and the whole thing is backed by [Netlify](https://www.netlify.com/) which helps manage the authentication and provides work-in-progress builds for content previews etc. The Netlify service back-end is [here](https://app.netlify.com/sites/ukwa-site/).

The idea is that curators and collaborators can edit and translate content without requiring any technical support.  When they are happy with the content, it can be rolled out onto the production web domain.

### Editorial Workflow

The current work-in-progress site is at: https://ukwa-site.netlify.app/en/ukwa/

The editing interface is at: https://ukwa-site.netlify.app/admin/

Users can log into the editor using GitHub. They can then select different pages, and edit the pages or their translations.  The system is currently configured to support the [_editorial workflow_ publishing mode](https://www.netlifycms.org/docs/configuration-options/#publish-mode).  This means each edit creates a separate set of changes, that can be reviewed and accepted on GitHub.  This needs to be evaluated, as it depends on there being someone willing to review all changes to the site.  If this workflow is not working, we can switch to making changes directly to the work-in-progress site.

Note that none of this changes the live site.  Whenit is time to roll out an update version of the live site, the UKWA tech team need to be told to create a new version of the site (by tagging this repository) and then update the `ukwa-services` stack to roll the new website out to BETA and then PROD. Again, if this workflow is not working, it can be reviewed, and we can look into rolling out changes in a more automated fashion.

## Deployment

The Docker build compiles the content and then patches it into an NGINX container.  The Docker Compose file can be used to do this locally, but GitHub Actions are used to automatically update container images.

These images are then referenced in `ukwa-services` in the `website` stack, which adds a more complex NGINX configuration that makes this content accessible where appropriate, but passed through and proxies through to other services as needed.

## Future Work

Hugo is nice and fast, but is quite opinionated in that it forces a lot of structure (e.g. the different Bundles) that we don't really need, and the templating system effectively requires you to have a basic understanding of the Go language (potentially meaning we need a wider range of skills to maintain this long term).  There are also limitations in how well it can integrate with the JavaScript frameworks that will necessarily be used to develop the site itself. See e.g. [this example of the issues and difficulties when developing React and Vue apps (respectively) on Hugo](https://forum.vuejs.org/t/how-do-i-get-vue-to-work-with-hugo-server/115628).

Longer term, it would make sense to move this site to a framework that means we can focus on JavaScript + markup, in particular one of the modern ones that make it easy to mix statically-generated, server-generated, and client-side deployment:

- [Nuxt](https://nuxtjs.org/) - site generator system focussed on Vue
- [Astro](https://astro.build/) - site generator system that is framework-agnostic, allowing different pages to be React/Vue/whatever.

