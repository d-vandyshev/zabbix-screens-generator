# Zabbix Screens Generator

Web application for creating screens per host with all its graphs

## Table of contents

   * [Deployed on Heroku](#deployed-on-heroku)
   * [Installation](#installation)
   * [Usage](#usage)
   * [Technology stack](#technology-stack)
   * [Security](#security)

## Deployed on Heroku

https://zabbix-screens-gen.herokuapp.com

With this instance on Heroku you can create screens if your Zabbix server is accessible from the Internet.

_The app is deployed on a free dyno. Free dynos will sleep after a half hour of inactivity. This causes a delay of a few seconds for the first request upon waking. Subsequent requests will perform normally_  

## Installation
 
Assuming that you have already installed Git, Ruby, NodeJS

1. git clone https://github.com/d-vandyshev/zabbix-screens-generator
1. cd zabbix-screens-generator
1. bundle install
1. rails server

That runs a local webserver. On a local machine, paste the URL http://localhost:3000 into the address bar of your browser.

## Usage

1. Open URL http://localhost:3000 and enter Zabbix credentials
![Zabbix Screen Generator - Login page](screenshots/Screen1_Login.png)
1. Select Host group
![Zabbix Screen Generator - Select Hostgroup page](screenshots/Screen2_SelectHostgroup.png)
1. Select the hosts for which you want to create screens
![Zabbix Screen Generator - Select Hosts page](screenshots/Screen3_CheckHosts.png)
1. Page with statuses
![Zabbix Screen Generator - Select Hosts page](screenshots/Screen4_Result.png)

## Technology stack

| Element       | Tool                  |
| ------------- | --------------------  |
| Web framework | _Ruby on Rails 5.1.4_ |
| Design        | _Froala blocks_       |
| CSS framework | _Bootstrap 4_         |
| Icons         | _SVG evil_icons_      |
| JS Framework  | _Stimulus_            |

## Security

* Place for Zabbix credentials (server, username, password): _not stored_
* Place for Zabbix instance: _save in memory (Rails.cache) of the server for current session_
