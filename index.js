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
       
const gitCloneCmd    = `git clone https://github.com/cerberustesting/cerberus-github-action.git`;
const chmodCmd    = `chmod +x cerberus-github-action/launchTest.sh`;
const launchTestCmd = `cerberus-github-action/launchTest.sh -a ${author} -h ${host} -c ${campaign} -k ${apikey}`;

log(`AUTHOR: ${getInputStr(author)}`);
log(`HOST: ${getInputStr(host)}`);
log(`CAMPAIGN: ${getInputStr(campaign)}`);


log('clone project...');
log(gitCloneCmd);
execSync(gitCloneCmd, { stdio: 'inherit' });

log('Changing Rights...');
log(chmodCmd);
execSync(chmodCmd, { stdio: 'inherit' });

log('Executing script...');
log(launchTestCmd);
execSync(launchTestCmd, { stdio: 'inherit' });
