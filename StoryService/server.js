const express = require("express")
const mongoose = require("mongoose")

const app = express()
const port = 3000

require('./config/app')(app, express)
require('./config/mongoose')(mongoose)
require('./config/routes')(app)

require('./config/listen')(app, port)
