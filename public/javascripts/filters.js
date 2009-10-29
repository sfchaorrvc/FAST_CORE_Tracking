Event.addBehavior({ 
  '#search_account_id_equals:change' : function() {
    this.form.method = 'get'
    this.form.submit()
  },

  '#search_profile_id_equals:change' : function() {
    this.form.method = 'get'
    this.form.submit()
  }
});
