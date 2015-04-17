module Folio

def get_folios
    @folios = []
    File.readlines(ENV["FOLIO_LIST"].to_s).each do |line|
      line = line.sub('Reg_12_', '').sub('.jp2', '')
      line = remove_carriage_returns(line)
      line_array = line.split("_")
      folio = line_array[0]
      folio_face = line_array[1]
      @folios << 'Folio ' + folio + ' - ' + folio_face
    end
  end

  def get_next_image(type)

    folio_all_lines = get_folios
    number_of_folios = folio_all_lines.length

    current_folio = 'Reg_12_' + session[:folio] + '_' + session[:folio_face].sub('_', ' ') + '.jp2'

    folio_all_lines.each_with_index do |folio_line, index|

      folio_line = remove_carriage_returns(folio_line)

      if folio_line == current_folio

        if type == '+'
          next_folio = folio_all_lines[index + 1]
        else
          next_folio = folio_all_lines[index - 1]
        end

        # Set the image path
        next_folio = remove_carriage_returns(next_folio)
        session[:image] = next_folio.sub(' ', '_') # DZI image expects an underscore and not a space, e.g. 'Insert_a'

        # Set the session variables
        temp = next_folio.sub('Reg_12_', '').sub('.jp2', '')
        temp_array = temp.split("_")
        folio = temp_array[0].strip
        folio_face = temp_array[1].strip.sub(' ', '_')
        session[:folio] = folio
        session[:folio_face] = folio_face
        session[:folio_choice] = 'Folio ' + folio + ' - ' + temp_array[1].strip
        break
      end
    end
  end

  def remove_carriage_returns(str)
    str = str.strip
    return str.sub(/\r/, " ").sub(/\n/, " ")
  end

  def get_folio
    session[:register_choice] = params[:register_choice].strip
    session[:folio_choice] = params[:folio_choice].strip
    register_params = params[:folio_choice] || ''
    if register_params != ''
      folio_array = register_params.split '-'
      folio = folio_array[0].sub('Folio ', '').strip
      folio_face = folio_array[1].strip.sub(' ', '_')
      session[:folio] = folio
      session[:folio_face] = folio_face
    end
    session[:image] = 'Reg_12_' + session[:folio] + '_' + session[:folio_face] + '.jp2'
  end

  def get_first_and_last_folio
    folio_all_lines = get_folios
    first_folio = folio_all_lines[0].strip.sub('.jp2', '').sub(' ', '_')
    last_folio = folio_all_lines[folio_all_lines.length - 1].strip.sub('.jp2', '')
    session[:first_folio] = first_folio
    session[:last_folio] = last_folio
  end

end