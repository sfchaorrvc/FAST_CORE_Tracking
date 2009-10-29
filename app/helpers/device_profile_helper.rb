module DeviceProfileHelper
  def select_device_profile(search_params)
    label_tag('search[profile_id_equals]', '<strong>and/or device profile:</strong>') + ' ' +
      select_tag('search[profile_id_equals]', build_device_profile_options(search_params))
  end
  
  private
  def build_device_profile_options(search_params)
    selected_id = search_params.nil? ? '' : search_params[:profile_id_equals]
    returning "" do |options|
      options << options_for_select([['All', '']], selected_id)
      options << '<option disabled="disabled">--------------</option>>'
      options << options_from_collection_for_select(DeviceProfile.all, :id, :name, selected_id.to_i)
    end
  end
end
