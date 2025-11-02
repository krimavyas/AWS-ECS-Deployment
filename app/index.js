const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (_req, res) => res.send('Hello World'));
app.get('/health', (_req, res) => res.status(200).json({ status: 'ok' }));

app.listen(PORT,'0.0.0.0' ,() => console.log(`App listening on ${PORT}`));
