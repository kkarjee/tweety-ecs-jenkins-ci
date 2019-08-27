const express = require('express')
const app = express()
const port = 80
app.get('/', (req, res) => res.send('Tweet Tweet Tweet Twwet !!!!!!!!!!! Tweet Twweet!!'))
app.listen(port, () => console.log(`Tweety app listening on port ${port}!`))
