namespace :tmp do
  desc "TODO"
  task tei: :environment do

    fl = File.open("/home/geekscruff/tmp/journal.csv", "w+")

    # write header row

    fl.write('dc:type,dc:type,dc:publisher,dc:source,main,dc:title,dc:description')
    fl.write('dc:creator,' * 20) # this is not a fixed number, I figured out the maximum number
    fl.write("\n")

    # we know that we are looking at a structure like this /vol/num/files

    Dir.entries("/home/geekscruff/tmp/grobidoutput/").each do | vol |
      if vol != '..' and vol != '.'
        Dir.entries("/home/geekscruff/tmp/grobidoutput/" + vol).each do | num |
          if num != '..' and num != '.'
            Dir.entries("/home/geekscruff/tmp/grobidoutput/" + vol + "/" + num).each do | art |

              if art != '..' and art != '.' and art.end_with? 'xml'

                f = File.open("/home/geekscruff/tmp/grobidoutput/"  + vol + "/" + num + "/" + art)
                @doc = Nokogiri::XML(f)
                f.close

                dctype = 'http://purl.org/dc/dcmitype/Text,http://purl.org/eprint/type/ScholarlyText'
                pub = 'OSA Publishing'
                source = '"Journal of the Optical Society of America B, ' + vol + '(' + num + ')"'
                main = vol + '/' + num  + '/' + art.sub('.tei.xml','.pdf')
                title = ''
                abstract = ''
                creators = []


                @doc.css('TEI teiHeader').each do |i|
                  i.css('fileDesc sourceDesc biblStruct analytic persName').each_with_index do | a, index |
                    if index > 20
                     puts index
                    end
                    c = a.css('surname').text + ','

                    a.css('forename').each do |fn|
                      c += ' ' + fn.text
                    end
                    creators += ['"' + c + '"']
                  end

                  title = '"' + i.css('fileDesc sourceDesc biblStruct analytic title').text + '"'

                  i.css('profileDesc abstract p').each do |p|
                    abstract += '"' + p.text + ' ' + '"'
                  end
                end
                line = dctype + ',' + pub + ',' + source.sub!('vol', '') + ',' + main + ',' + title + ',' + abstract
                creators.each do | c |
                  line += ',' + c
                end
                fl.write(line)
                fl.write("\n")
              end
            end
          end
        end
      end
    end

    fl.close

  end
end
