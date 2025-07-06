# Wordpress Template Validator

This mini-project uses GitHub Actions, JavaScript, and Shell scripting to fetch and validate content from a WordPress site.

It automatically pulls the 5 most recent posts from a WordPress.com site and checks whether each one follows a specific HTML structure. If a post fails validation, a validation-report.md file is generated with details on the deviations.

Each post is expected to include:

- A <title> element

- A meta description (<meta name="description">)

- At least one image tag (<meta property="og:image">)

- Alt text for each image to ensure accessibility


# How it Works

1. fetch-posts.js --> Fetches the latest 5 posts from the WordPress REST API and saves them as HTML files in the /content directory.

2. check-metadata.sh --> Validates each HTML file for required metadata (<title>, <meta name="description">, <meta property="og:image">, and content structure).
Fails the GitHub Action if any post is missing required elements.

3. GitHub Actions Workflow --> Runs on every push or pull request, automatically fetching content and validating it as part of your CI/CD pipeline.
