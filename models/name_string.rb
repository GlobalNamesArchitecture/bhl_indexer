class NameString < ActiveRecord::Base
  has_many :page_name_strings

  def self.normalize(name_string)
    name_ary = name_string.split(" ")
    words_num = name_ary.size
    res = nil
    if words_num == 1
      res = name_ary[0].gsub(/[\(\)\{\}]/, '')
      if res.size > 1
        res = UnicodeUtils.upcase(res[0]) + UnicodeUtils.downcase(res[1..-1])
      else
        res = nil
      end
    else
      if name_ary[0].size > 1
        word1 = UnicodeUtils.upcase(name_ary[0][0]) + UnicodeUtils.downcase(name_ary[0][1..-1])
      else
        word1 = name_ary[0]
      end
      if name_ary[1].match(/^\(/)
        word2 = name_ary[1].gsub(/\)$/, '') + ")"
        word2 = word2[0] + UnicodeUtils.upcase(word2[1]) + UnicodeUtils.downcase(word2[2..-1])
      else
        word2 = UnicodeUtils.downcase(name_ary[1])
      end
      res = word1 + " " + word2 + " " + name_ary[2..-1].map { |w| UnicodeUtils.downcase(w) }.join(" ")
      res.strip!
    end
    res
  end
end
