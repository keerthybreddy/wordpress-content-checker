const axios = require('axios');
const fs = require('fs');
const path = require('path');

async function fetchPosts() {
  try {
    const res = await axios.get('https://public-api.wordpress.com/wp/v2/sites/testcontentpreprocessor.wordpress.com/posts?per_page=5');
    const posts = res.data;

    // Ensure the content directory exists
    const contentDir = path.join(__dirname, 'content');
    if (!fs.existsSync(contentDir)) {
      fs.mkdirSync(contentDir);
    }

    // Loop over posts and create HTML files
    posts.forEach((post, index) => {
      const title = post.title?.rendered || 'Untitled';
      const description = post.excerpt?.rendered?.replace(/<[^>]+>/g, '') || 'No description available';
      const image = 'https://via.placeholder.com/1200x630'; // Placeholder or use featured_media if available
      const content = post.content?.rendered || '';

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

      const filename = path.join(contentDir, `post-${index + 1}.html`);
      fs.writeFileSync(filename, html.trim());
      console.log(`Saved ${filename}`);
    });
  } catch (err) {
    console.error("Error fetching posts:", err.message);
    process.exit(1); // Fail the GitHub Action
  }
}

fetchPosts();