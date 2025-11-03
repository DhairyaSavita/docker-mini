const express = require('express');
const path = require('path');
const app = express();
const port = 3000;

app.use(express.static(path.join(__dirname, 'build')));

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'build', 'index.html'), (err) => {
    if (err) {
      res.send("<h1>Hello from the Node.js Server! Build folder not found.</h1>");
    }
  });
});

app.listen(port, () => {
  console.log(`Application is running on http://localhost:${port}`);
});