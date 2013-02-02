# Slide Collector

downloader for slides on SlideShare and Speaker Deck

## Notice

this is alpha version.
includes many dependency with target site's HTML structures.
please try with your own responsibility.

## Install

    git clone git://github.com/itzki/slide_collector.git
    cd slide_collector
    bundle install

### Setting

- to use SlideShare API, you need to apply on http://www.slideshare.net/developers/applyforapi
- then, set your keys to `SLIDESHARE_API_KEY` and `SLIDESHARE_SHARED_SECRET` environment variables
 - easy to use [dotenv](https://github.com/bkeepers/dotenv)

## Usage

### Normal

    #for SlideShare
    ruby slideshare.rb
    #for Speaker Deck
    ruby speakerdeck.rb

slides will be saved into "./slides" directory.

### Saving specific directory

    ruby slideshare.rb -d /path/to/dist

### Starting from specific offset (on Hatena bookmark)

    ruby slideshare.rb -o 100

## Features

- depends on Hatena bookmark's entry list (to sort out good slides)
 - ref: http://b.hatena.ne.jp/entrylist?sort=hot&url=http%3A%2F%2Fwww.slideshare.net
- first time, continually download slides unless it reached last one or error occured
- next time, download only new slides that someone bookmarked

### SlideShare

- even if download is not available, try to generate PDF from every page image

## Supported versions

- Ruby 1.9.2 or higher
