/**
1;95;0c * Created by pawan deshpande on 06-Jan-2021 
*/
const express = require('express');
const app = express();
require('dotenv').config();

var AWS = require('aws-sdk');
//Auth secret used to authentication notification requests.
let AUTH_SECRET = "highrisehub1234"; //process.env.AUTH_SECRET;


if (!AUTH_SECRET) {
  return console.error("AUTH_SECRET environment variable not found.");
}
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static("static"));


app.get("/sms/status", function(req, res) {
  res.send("HighriseHub AWS SNS SMS Server Running!");
});



app.get('/sms/sendsms', (req, res) => {

    if (req.get("auth-secret") != AUTH_SECRET) {
	console.log("Missing or incorrect auth-secret header. Rejecting request.");
	return res.sendStatus(401);
    }
    
    console.log("Message = " + req.query.message);
    console.log("Number = " + req.query.number);
    console.log("SenderID = " + req.query.senderid);
    var params = {
        Message: req.query.message,
        PhoneNumber: req.query.number,
        MessageAttributes: {
            'AWS.SNS.SMS.SenderID': {
                'DataType': 'String',
                'StringValue': req.query.senderid
            }
        }
    };

    var publishTextPromise = new AWS.SNS({ apiVersion: '2010-03-31' }).publish(params).promise();

    publishTextPromise.then(
        function (data) {
            res.end(JSON.stringify({ MessageID: data.MessageId }));
        }).catch(
            function (err) {
                res.end(JSON.stringify({ Error: err }));
            });

});

app.listen(4300, () => console.log('SMS Service Listening on PORT 4300'));
