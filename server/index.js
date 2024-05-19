const express = require("express");
const bodyParser = require("body-parser");
const https = require("https");
const cors = require("cors");
require('dotenv').config();
const sqlite3 = require("sqlite3").verbose();

const PORT = 3005;
const corsOptions = {
    origin: "*", // allow access to this origin
    optionsSuccessStatus: 200 // legacy browsers
};
const app = express();
// specify middlewares
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
// CORS rules
app.use(cors(corsOptions))
// start server
app.listen(PORT);

// open db
let alarms_db = new sqlite3.Database("./db/alarms.db");
let clocks_db = new sqlite3.Database("./db/clocks.db");

// verify credentials
function verifyCreds(clock, pass) {
    clocks_db.get("SELECT * FROM Clocks WHERE Clock = ? AND Pass = ?", [clock, pass], (err) => {
        return !err;
    });
    return false;
}

// landing page
app.get("/", (req, res) => {
    console.log("\nGET /");
    res.send("Smart Clock Server is running!")
});

app.post("/verify", (req, res) => {
    console.log("\nPOST /verify");
    const auth_header = req.headers.authorization;
    if (!auth_header)
        return res.status(401).send("Unauthorized request");
    let auth = null;
    try {
        auth = new Buffer.from(auth_header.split(" ")[1], "base64").toString();
    } catch (err) {
        return res.status(400).send(err.message);
    }
    if (auth == process.env.PASS)
        return res.send("Valid")
    return res.status(401).send("Invalid")
});

app.post("/register-clock", (req, res) => {
    console.log("\nPOST /register-clock");
    clocks_db.run("INSERT INTO Clocks(Clock, Pass) VALUES (?, ?)", [req.body.clock, req.body.pass], (err) => {
        if (err)
            return res.status(400).send(err.message);
        return res.send("Registered clock to db")
    })
});

// add alarm to db
app.post("/add-alarm", (req, res) => {
    console.log("\nPOST /add-alarm");
    // parse authentication header
    const auth_header = req.headers.authorization;
    if (!auth_header)
        return res.status(401).send("Unauthorized request");
    let auth = null;
    try {
        auth = new Buffer.from(auth_header.split(" ")[1], "base64").toString().split(":");
    } catch (err) {
        return res.status(400).send("An error occured while parsing the provided basic auth header");
    }
    const clock = auth[0];
    const pass = auth[1];
    if (!verifyCreds(clock, pass))
        return res.status(401).send("Invalid credentials");

    let time = req.body.time;
    let routine = req.body.routine;
    alarms_db.run("INSERT INTO Alarms(Time, Routine) VALUES(?, ?)", [time, routine], (err) => {
        if (err)
            return res.status(400).send(err.message);
        return res.send("Added alarm");
    });
});
