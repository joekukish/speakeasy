# Speakeasy

Speakeasy is a ruby library that maps a language to the minimum set of
unicode codepoints required to represent it. Full support requires every
mandatory character in the profile, including its required punctuation,
currency characters, and numerals. There is no universal ASCII baseline.

## Language definition format

All languages will be referenced by their [IANA language subtags][iana].

Each language's data is a standalone YAML file contained in the data directory
of this project.

    data/
      ca
      cs
      de
      ...

Each YAML file will have the following keys and must be saved in UTF8:

* `version` (currently 2)
* `anglicized_name` (the language name in English)
* `native_name` (the name of the language in the language)
* `codepoints` (currently a list of ranges or a single codepoint see [data/en](tree/master/data/en) for an example).

An example YAML file:

    ---
    version: 2
    anglicized_name: English
    native_name: English
    codepoints:
    - !ruby/range 65..90 # Uppercase
    - !ruby/range 97..122 # Lowercase

Note: codepoints should only include normalized unicode codepoints.

## Experimental independent capabilities

`Speakeasy::Language.all`, `.each`, and `.supported_language_ids` still enumerate
the 78 existing language/script profiles. Capability definitions live separately
under `capabilities/` and never become primary-language candidates.

| Capability | Required glyphs |
| --- | --- |
| `Zmth-basic` | `0123456789+-*/=−×÷±<>≤≥≠(),.%` (29) |
| `Zsym-publishing` | `©®™§¶•†‡…°&@#` (13) |

```ruby
Speakeasy::Capability.each do |capability|
  if capability.supported_by?(font_codepoints)
    puts capability.capability_id
  end
end
```

Each capability requires every listed scalar. A single `+` does not imply the
whole math capability. Missing a capability glyph does not revoke otherwise valid
language coverage, and math glyph coverage does not certify OpenType MATH tables
or mathematical typesetting. These are product-scoped identifiers using ISO
15924 prefixes, not language/locale tags or exhaustive script inventories.

Only `#`, `&`, `=`, `@`, `×`, and `÷` leave the 65 generated nonlegacy language
minima. Digits, currency, ordinary punctuation, reviewed letters, and the 13 frozen
public definitions remain unchanged. Overlap with language requirements is
intentional. `parlance-source.json` pins the producer revision and artifact hashes.

## Example

    require 'rubygems'
    require 'speakeasy'

    Speakeasy::Language.each do |language|
      print "#{language.anglicized_name} (#{language.native_name}) "
      puts language.codepoints[0..10].inspect
    end

It should return

    Catalan (Català) [65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75]
    Czech (Česky) [65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75]
    German (Deutsch) [65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75]
    English (English) [65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75]
    ....

## Contributing

* Fork speakeasy
* Create a topic branch - `git checkout -b my_lang`
* Create or edit `data/my_lang`
* Verify it's correctly formatted - `rake test[my_lang]`
* Verify it has all the characters you want - `rake visualize[my_lang]`
* Push to your branch - `git push origin my_lang`
* Create a github pull request.
* That's it!


## Resources

* [Language Tags RFC5646](http://tools.ietf.org/rfc/bcp/bcp47.txt)
* [http://www.langtag.net/](http://www.langtag.net/)
* [http://github.com/runpaint/unicode-data](http://github.com/runpaint/unicode-data)


## Author

Matt Colyer / matt@typekit.com

## Copyright and License

Copyright (c) 2010 Adobe Systems Incorporated. Licensed under the Apache 2.0 license

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

[iana]: http://www.iana.org/assignments/language-subtag-registry
