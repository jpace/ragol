ragol(1) - Ragol: Another GetOpt Library
========================================

## DESCRIPTION

Ragol is a module for processing command-line options. It supports much of the
functionality of OptParse, and offers a more class-oriented structure for
defining options.

Options can have value types, such as float, fixnum, string, or regular
expressions, resulting in the value being validated against the value type. An
option can have a required or optional value.

Unlike OptParse, Ragol supports regular expressions as the options themselves.
For example, this option (from the context option for Glark) accepts a tag in
the form "--123":

```
optdata << {
  :regexp    => %r{ ^ - ([1-9]\d*) $ }x,
  :valuetype => :integer,
  :set       => Proc.new { |val| @context = val || 2 },
}
```
## CLASSES

### Ragol::OptionSet

A set of options. This can be instantiated with an array of option data.

Each element of the option data has the following fields:

  * `:regexps`:
    An array of regular expressions that will match the tag itself.

  * `:tags`:
    An array of tags as strings, either long form (--foo) or short (-f).

  * `:rcnames`:
    An array of names to match fields in an rc file.

  * `:takesvalue`:
    One of true, :optional, or false, denoting whether the tag takes a value.
    The default is false.

  * `:valuetype`:
    The type of value that the option takes. Valid values: :boolean, :string,
    :float, :integer, :fixnum, :regexp.

  * `:valueregexp`:
    The regular expression to match the value that the tag accepts.

  * `:default`:
    The default value.

  * `:process`:
    A proc to call when the option is set. The arguments are |val, optset,
    args|; val is the value; optset is the set of options, and args is the array
    of unprocessed arguments.

  * `:postproc`:
    A proc to call after all options are set. The arguments are |optset,
    results, unprocessed|.

  * `:description`:
    The description of the option.

See examples for more.

### Ragol::Option

An option that does not take a value.

### Ragol::FixnumOption

An option that takes a fixnum (integer).

### Ragol::FloatOption

An option that takes a float.

### Ragol::StringOption

An option that takes a string.

## EXAMPLES



## AUTHOR

Jeff Pace (jeugenepace at gmail dot com)

http://www.github.com/jpace/ragol
