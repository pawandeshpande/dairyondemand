/**
1;95;0c * Created by pawan deshpande on 06-Jan-2021 
*/
const express = require('express');
const app = express();
require('dotenv').config();

var AWS = require('aws-sdk');


app.get("/sms/status", function(req, res) {
  res.send("HighriseHub AWS SNS SMS Server Running!");
});



app.get('/sms/sendsms', (req, res) => {

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
