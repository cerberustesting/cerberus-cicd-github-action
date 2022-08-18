const os           = require('os');
const { execSync } = require('child_process');
const { getInput } = require('@actions/core');

function log (message) {
    console.log(message);
}

function getInputStr (argValue) {
    if (!argValue)
        return 'not specified';

    return argValue;
}

const author = getInput('author');
const host = getInput('host');
const campaign = getInput('campaign');
const apikey = getInput('apikey');
const country = getInput('country')==="" ? "" : "-C " + getInput('country');
const environment = getInput('environment')==="" ? "" : "-E " + getInput('environment');
const robot = getInput('robot')==="" ? "" : "-R " + getInput('robot');
const tag = getInput('tag')==="" ? "" : "-T " + getInput('tag');
       
const gitCloneCmd    = `git clone https://github.com/cerberustesting/cerberus-cicd-github-action.git`;
const chmodCmd    = `chmod +x cerberus-cicd-github-action/launchTest.sh`;
const launchTestCmd = `cerberus-cicd-github-action/launchTest.sh -a ${author} -h ${host} -c ${campaign} -k ${apikey} ${country} ${environment} ${robot} ${tag}`;

log(`AUTHOR: ${getInputStr(author)}`);
log(`HOST: ${getInputStr(host)}`);
log(`CAMPAIGN: ${getInputStr(campaign)}`);
log(`OVERRIDE COUNTRY: ${getInputStr(country)}`);
log(`OVERRIDE ENVIRONMENT: ${getInputStr(environment)}`);
log(`OVERRIDE ROBOT: ${getInputStr(robot)}`);
log(`OVERRIDE TAG: ${getInputStr(tag)}`);


log('clone project...');
log(gitCloneCmd);
execSync(gitCloneCmd, { stdio: 'inherit' });

log('Changing Rights...');
log(chmodCmd);
execSync(chmodCmd, { stdio: 'inherit' });

log('Executing script...');
log(launchTestCmd);
execSync(launchTestCmd, { stdio: 'inherit' });
