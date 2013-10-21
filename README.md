# ComponentSwarm

TODO: 

## Installation

Add this line to your application's Gemfile:

    gem 'component_swarm'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install component_swarm

## Usage

TODO:

### Component structure

#### manifest.json

```json
{
  "css": [
    "main",
    "header",
    "body"
  ],
  "js": [
    "main"
  ],
  "libs": [
    "jquery"
  ],
  "dependencies": [
    "component_2"
  ]
}
```

#### File Structure

```sh
app/assets/components/
├── component_1
│   ├── css
│   │   ├── body.css.scss
│   │   ├── header.css.scss
│   │   └── main.css.scss
│   ├── js
│   │   └── main.js
│   └── manifest.json
└── component_2
    ├── css
    │   └── main.css.scss
    └── manifest.json
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
