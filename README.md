ragol(1) - Ragol: Another GetOpt Library
========================================

## DESCRIPTION

Ragol is a module for processing command-line options. It supports much of the
functionality of OptParse, and offers a more class-oriented structure for
defining options.

Options can have value types, such as float, fixnum, string, or regular
expressions, resulting in the value being validated against the value type. An
option can have a required or optional value.

## CLASSES

### Ragol::Option

An option that does not take a value.

### Ragol::FixnumOption

An option that takes a fixnum (integer).

### Ragol::FloatOption

An option that takes a float.

### Ragol::StringOption

An option that takes a string.

## AUTHOR

Jeff Pace (jeugenepace at gmail dot com)

http://www.github.com/jpace/ragol

