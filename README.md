# Run Cerberus GitHub Action

This action trigger a [Cerberus](https://github.com/cerberustesting/cerberus-source) campaign execution and check for the result.

## Usage

```yaml
- uses: bcivel/cerberus-github-action@v9
  with:
    host: https://jftl.cerberus-testing.com
    campaign: API_NonRegression_UAT
    apikey: ${{ secrets.APIKEY }}
    author: ${{ github.event.pusher.name }}
```

In this example, the [Cerberus](https://github.com/actions/cerberus-bci) action trigger the execution of the campaign on the cerberus instance behind the host, using the APIKEY.
The author is used for the tag automatic generation, in order to link the execution with the people who trigger it.

## Options

### host

Your Cerberus host.

```yaml
- uses: bcivel/cerberus-github-action@v9
  with:
    host: https://my_instance.cerberus-testing.com
```

### campaign

The Campaign name you want to execute.

```yaml
- uses: bcivel/cerberus-github-action@v9
  with:
    campaign: My_Campaign
```

### author

The name of the people that trigger the execution. It can be a generic name, or the name of the committer 

```yaml
- uses: bcivel/cerberus-github-action@v9
  with:
    author: ${{ github.event.pusher.name }}
```

### apikey

The apikey of your cerberus instance. You can hardcode it directly, of use the Secrets  

```yaml
- uses: bcivel/cerberus-github-action@v9
  with:
    apikey: AS23DVFERS45677GFDDVGREZ3345TGGHH554EDR
```

```yaml
- uses: bcivel/cerberus-github-action@v9
  with:
    apikey: ${{ secrets.APIKEY }}
```

### timeout

*Optional*

The number of seconds from which the execution will consider it's a fail

```yaml
- uses: bcivel/cerberus-github-action@v9
  with:
    timeout: 500
```

**Default value:** 300

## Examples

This section contains sample workflows that show how to use `cerberus-action`.

### Run Cerberus Tests

The following workflow shows how to use `cerberus-action` in a simple scenario:

```yaml
name: My Quality Workflow
on: [push]

jobs:
  build:
    name: Run Cerberus Tests
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: cerberus-action
      uses: bcivel/cerberus-github-action@v9
      with:
        host: https://jftl.cerberus-testing.com
        campaign: API_NonRegression_UAT
        apikey: ${{ secrets.APIKEY }}
        author: ${{ github.event.pusher.name }}
```
