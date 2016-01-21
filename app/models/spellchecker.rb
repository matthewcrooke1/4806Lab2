require 'set'

class Spellchecker

  
  ALPHABET = 'abcdefghijklmnopqrstuvwxyz'

  #constructor.
  #text_file_name is the path to a local file with text to train the model (find actual words and their #frequency)
  #verbose is a flag to show traces of what's going on (useful for large files)
  def initialize(text_file_name)
	@dictionary = Hash.new(0)	
	File.open(text_file_name, "r").each do |line|
	train!(words(line))
	end
    #read file text_file_name
    #extract words from string (file contents) using method 'words' below.
    #put in dictionary with their frequency (calling train! method)
  end

  def dictionary
    return @dictionary.toHash
    #getter for instance attribute
  end
  
  #returns an array of words in the text.
  def words (text)
    return text.downcase.scan(/[a-z]+/) #find all matches of this simple regular expression
  end

  #train model (create dictionary)
  def train!(word_list)		
	word_list.each  do |word|		
	@dictionary[word] += 1
	end
	
    #create @dictionary, an attribute of type Hash mapping words to their count in the text {word => count}. Default count should be 0 (argument of Hash constructor).
  end

  #lookup frequency of a word, a simple lookup in the @dictionary Hash
  def lookup(word)
       @dictionary[word]
  end
  
  #generate all correction candidates at an edit distance of 1 from the input word.
  def edits1(word)
    #all strings obtained by deleting a letter (each letter)
    index = 0
    deletes = []
    word.each_char do |char|
      temp = String.new(word)
      temp.slice!(index)
     deletes.insert(-1, temp)
    index+=1
    end
   
   

    transposes = []
    index2 = 0
    
    word.each_char do |x|
      if index2+1 < word.size
      temp2 = String.new(word)
      letter = String.new(temp2.slice!(index2))
      temp2.insert(index2+1, letter)
      transposes.insert(-1, temp2)
      index2+=1
      end
    end
    #all strings obtained by switching two consecutive letters
  
  # all strings obtained by inserting letters (all possible letters in all possible positions)
    index1 = 0
    inserts = []
   word.each_char do |x|
   ALPHABET.each_char do |char|
      temp1 = String.new(word)
      temp1.insert(index1, char)
      inserts.insert(-1, temp1)
       if index1 == word.size-1
         temp1 = String.new(word)
      temp1.insert(index1+1, char)
      inserts.insert(-1, temp1)
       end
     end
      index1+=1
    end
    
    replaces = []
    index3 = 0
     word.each_char do |q|
       ALPHABET.each_char do |s|
      temp3 = String.new(word)
      temp3.slice!(index3)
      temp3.insert(index3, s)
      replaces.insert(-1, temp3)
    end
    index3+=1
  end
    
    
    #all strings obtained by replacing letters (all possible letters in all possible positions)

    return (deletes + transposes + replaces + inserts).to_set.to_a #eliminate duplicates, then convert back to array
  end
  

  # find known (in dictionary) distance-2 edits of target word.
  def known_edits2 (word)
    # get every possible distance - 2 edit of the input word. Return those that are in the dictionary.
    array = Array.new(0)
    edits1(word).each do |x|
      known(edits1(x)).each do|y|
     if(array.rindex(y) == nil)
      array.insert(-1,y)
     end
    end
  end
 return array
  end

  #return subset of the input words (argument is an array) that are known by this dictionary
  def known(words)
    return words.find_all {|word| @dictionary.key?(word) } #find all words for which condition is true,
                                    #you need to figure out this condition
    
  end


  # if word is known, then
  # returns [word], 
  # else if there are valid distance-1 replacements, 
  # returns distance-1 replacements sorted by descending frequency in the model
  # else if there are valid distance-2 replacements,
  # returns distance-2 replacements sorted by descending frequency in the model
  # else returns nil
def correct(word)
    temp = Array.new(0)
    if known([word]).size > 0
      return known([word])
     
     else if known(edits1(word)).size > 0
       return known(edits1(word)).sort! {|x,y| y<=>x}
     
     else if known(known_edits2(word)).size > 0
       known(known_edits2(word)).each do |x|
        if(temp).size > 0   
           temp.each do |y|
             
        if lookup(x) > lookup(y)
          if(temp.rindex(x) == nil)
         temp.insert(0, x)
          end
        end
   end
    else temp.insert(-1,x)
        end
   end
     return temp
      else
       return nil
      end
    end
    end
end  

  
end

