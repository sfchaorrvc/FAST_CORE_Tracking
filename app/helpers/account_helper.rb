module AccountHelper
  def select_account(search_params, unprovisioned = true)
    label_tag('search[account_id_equals]', '<strong>Filter by account:</strong>') + ' ' +
      select_tag('search[account_id_equals]', build_account_options(search_params, unprovisioned))
  end
  
  private
  def build_account_options(search_params, unprovisioned)
    selected_id = search_params.nil? ? '' : search_params[:account_id_equals]
    returning "" do |options|
      
      options << options_for_select([['All', '']], selected_id)
      options << options_for_select([['Unprovisioned', '0']], selected_id) if unprovisioned
      options << '<option disabled="disabled">--------------</option>>'
      options << options_from_collection_for_select(Account.all, :id, :company, selected_id.to_i)
    end
  end
end
