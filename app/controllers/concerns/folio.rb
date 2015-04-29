module Folio

  # Get the first and last folio in the folio list and store as session variables so that the image
  # '<' or '>' button is greyed out if folio is equal to the first or last one
  def get_first_and_last_folio
    folio_all_lines = get_folios
    first_folio = folio_all_lines[0].strip.sub('.jp2', '').sub(' ', '') # Note that the space is replaced at the end, e.g. 'Insert a' -> 'Inserta'
    last_folio = folio_all_lines[folio_all_lines.length - 1].strip.sub('.jp2', '')
    session[:first_folio] = first_folio
    session[:last_folio] = last_folio
  end

  # Set the register, folio and folio face session variables (i.e. those chosen from the drop-down lists) for the current folio
  # Note that the 'folio_choice' session variable contains both the folio and folio face (as it is used to remember the drop-down list choice)
  # but the variables are stored separately as 'folio' and 'folio_face' session variables (which are then saved in Fedora for the particular entry)
  def get_current_folio
    session[:register_choice] = params[:register_choice].strip
    session[:folio_choice] = params[:folio_choice].strip
    register_params = params[:folio_choice] || ''
    if register_params != ''
      folio_array = register_params.split '-'
      folio = folio_array[0].sub('Folio ', '').strip
      folio_face = folio_array[1].strip.sub(' ', '') # replacing space with '' in e.g. 'Insert a' because there seem to be problems storing ' ' and '_' in Fedora (ActiveFedora problem?)
      session[:folio] = folio # This is the 'folio' stored in Fedora
      session[:folio_face] = folio_face # This is the 'folio_face' stored in Fedora
    end
    # The image session variable defines the name of the jp2 image file in dlib
    # 'Reg_12' will need changing eventually when there are more registers
    session[:image] = 'Reg_12_' + session[:folio] + '_' + session[:folio_face].sub('Insert', 'Insert_') + '.jp2' # Note that Insert has an underscore after it in order to get the correct url, e.g. 'Inserta' -> 'Insert_a'
  end

  # Get the next image and set the session variables when the '> or '<' buttons are clicked'
  def get_next_image(button_action)

    folio_all_lines = get_folios # Basically an array of all the lines in the text file, i.e. all the folio names

    # 'Reg_12_' will need changing later on
    current_folio = 'Reg_12_' + session[:folio] + '_' + session[:folio_face].sub('Insert', 'Insert ') + '.jp2'
   
    # Iterate over all the folios
    folio_all_lines.each_with_index do |folio_line, index|

      folio_line = folio_line.chop.strip # remove carriage return and spaces

      # If the current folio matches with the line, find out the next folio name
      if folio_line == current_folio

        if button_action == 'forward'
          next_folio = folio_all_lines[index + 1]
        else
          next_folio = folio_all_lines[index - 1]
        end

        # Set the image path
        next_folio = next_folio.chop.strip # remove carriage return and spaces
        session[:image] = next_folio.sub(' ', '_') # DZI image expects an underscore and not a space, e.g. 'Insert_a'

        # Set the session variables
        temp = next_folio.sub('Reg_12_', '').sub('.jp2', '')
        temp_array = temp.split("_")
        folio = temp_array[0].strip
        folio_face = temp_array[1].strip.sub(' ', '') # replacing space with '' in e.g. 'Insert a' because there seem to be problems storing ' ' and '_' in Fedora (ActiveFedora problem?)
        session[:folio] = folio
        session[:folio_face] = folio_face
        session[:folio_choice] = 'Folio ' + folio + ' - ' + temp_array[1].strip
        break
      end
    end
  end

  # Read the folio text file lines into an array
  # Used in methods above and to display the folio drop-down list on the view pages
  # Note that I've left a blank line at the bottom because otherwise the last entry was truncated (maybe look into this sometime)
  def get_folios
    @folios = []
    File.readlines(ENV["FOLIO_LIST"].to_s).each do |line|
      line = line.sub('Reg_12_', '').sub('.jp2', '')
      line = line.chop.strip # remove carriage return and spaces
      line_array = line.split("_")
      folio = line_array[0]
      folio_face = line_array[1]
      @folios << 'Folio ' + folio + ' - ' + folio_face
    end
  end
end