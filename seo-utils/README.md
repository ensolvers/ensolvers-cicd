## Installation

2. Install dependencies: `yarn install`

## Usage

1. Add a list of URLs to a CSV file named `urls.csv` in the `sample_data` folder. Each URL should be on a separate line, without quotes or spaces.
2. Run the tests: `./run.sh`
3. To print Cypress output to the console, use the `-v` argument: `./run.sh -v`

## Dependencies

- node: `v20.0.0`

## Usage example
- ./run.sh -d data_entry/urls.csv -v  