# -*- encoding : utf-8 -*-
# config/locales/pluralizations/pl.rb
{:pl =>
  { :i18n =>
    { :plural =>
      { :keys => [:one, :few, :many, :other],
        :rule => lambda { |n|
          if n == 1
            :one
          elsif [2, 3, 4].include?(n % 10) && ![12, 13, 14].include?(n % 100)
            :few
          elsif (n != 1 && [0, 1].include?(n % 10)) || [5, 6, 7, 8, 9].include?(n % 10) || [12, 13, 14].include?(n % 100)
            :many
          else
            :other
          end
        }
      }
    }
  }
}
# http://unicode.org/repos/cldr-tmp/trunk/diff/supplemental/language_plural_rules.html
# one   → n is 1;
# few   → n mod 10 in 2..4 and n mod 100 not in 12..14;
# many  → n is not 1 and n mod 10 in 0..1 or n mod 10 in 5..9 or n mod 100 in 12..14;
# other → everything else
