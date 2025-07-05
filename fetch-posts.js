// import axios HTTP client library to make API requests
const axios = require('axios');

// import Node.js File System (fs) module to read and write files
const fs = require('fs');

// import Node.js Path module to work with file and directory paths
const path = require('path');

async function fetchPosts() {
  try {

    // Send a GET request to the WordPress API to fetch the 5 most recent posts made on the WordPress site in the URL and store response in res variable
    const res = await axios.get('https://public-api.wordpress.com/wp/v2/sites/testcontentpreprocessor.wordpress.com/posts?per_page=5');
    
    // Access the post data in JSON format using .data and store it in the variable posts
    const posts = res.data;

    // contentDir variable contains the absolute path to the content folder where HTML files of the Wordpress posts will be stored
    const contentDir = path.join(__dirname, 'content');

    // checks if the content folder already exisis and if not, creates it
    if (!fs.existsSync(contentDir)) {
        fs.mkdirSync(contentDir);
    }

    // Loop over each post returned by the API
    posts.forEach((post, index) => {

        // If post contains title, store it in title variable, else store placeholder text
        const title = post.title?.rendered || 'Untitled';

        // If post contains description, use Regex to extract text within tags and store it in description variable, else store placeholder text
        const description = post.excerpt?.rendered?.replace(/<[^>]+>/g, '') || 'No description available';

        // image variable is set to a placeholder value, but actual image check is made in check-metadata file
        const image = 'https://via.placeholder.com/1200x630';
      
        // If post contains any other content, store it in the content variable, else store placeholder text
        const content = post.content?.rendered || '';

        // Create a template HTML file using previously created metadata variables and store it in html variable
        const html = `
            <html>
                <head>
                    <title>${title}</title>
                    <meta name="description" content="${description}">
                    <meta property="og:image" content="${image}">
                </head>
                <body>
                    ${content}
                </body>
            </html>
      `;

        // Creates custom file paths within the content folder for each post that is fetched from the API call
        const filename = path.join(contentDir, `post-${index + 1}.html`);
      
        // html string variable contains data from each post, write each previously created file with the html string
        fs.writeFileSync(filename, html.trim());
        console.log(`Saved ${filename}`);
    });
  } catch (err) {

    // If any error is thrown while making the GET request or writing the data fetched to files within the repo, display the error here
    console.error("Error fetching posts:", err.message);
    
    // If an error occurs, fail the GitHub Action and exit the workflow completely
    process.exit(1);
  }
}

fetchPosts();