module LayoutHelper
  def javascript(*args)
    args = args.map { |arg| arg == :defaults ? arg : arg.to_s }
    content_for(:head) { javascript_include_tag(args, :cache => "#{args.join('_')}_cached") }
  end
end