This repository contains the common lisp source code for a E-Commerce Stores, Digital Marketplaces. You can create your own e-commerce SAAS application where you can host your customers. Your site will provide e-commerce store building capabilities for Individual Sellers/Social groups/Small communities who want to buy/sell goods and services. Some of the salient features of this project are as under. 
There are two kinds of people involved in this marketplace. The Customers and Vendors. It has got all the features of e-commerce marketplace such as 

* Orders 
* Product Subscriptions 
* Product listings 
* Order Management for Vendors.
* Product Management for Vendors. 
* Multiple Vendors per order. 
* Vendors have access to multiple groups/communities. 
* Standalone Vendor support. Using this feature, you can promote online selling for your own website. Orders from your website will be forwarded to www.highrisehub.com by default or you can copy the source code from this repository and create your own Digital Marketplace. 
* Payment modes supported are Online Payment, Cash On Demand and Prepaid Wallet. (For Indian Subcontinent Customers) 
* Progressive Web Application. 
* Browser Push Notification for Vendors. 
* For a detailed list of features please visit https://www.highrisehub.com/pricing

** How to setup the repository. **
* Procure a Ubuntu 20.02 server on Hyperscalers like AWS, GCP or MSFT Azure. 
* Hardware Requirements: A Medium speed server with 8 GB RAM and 100 GB Secondary storage. 
* We have hosted our site on AWS. You would need these AWS Services: EC2 for Compute, SES for Sending Email, SNS for sending SMS. 
* Install SBCL on Ubuntu 20.02. 
* Install Mysql 8.0
* Install Quicklisp
* Setup Slime for using emacs as in IDE for lisp programming. 
* Load the load.lisp file, which will download all the necessary common lisp libraries and also compile them. 
* Start the website using (start-das) command. 




