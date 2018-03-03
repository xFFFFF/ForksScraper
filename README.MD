# ForkScraper

An example of using Github's API to get all unique files from **multiple** repository forks by comparing SHA checksum of files. A script written in Linux Bash, uses curl and jq.

# Search query explanation
- authorized connections have a limit of 5,000 queries per hour
- the API search engine displays a maximum of 1000 results per query, so with more forks you have to decrase results range by date
