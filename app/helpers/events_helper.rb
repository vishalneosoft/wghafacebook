module EventsHelper
  def soundcloud(text)
    begin
      links = []
      text.gsub(/(https?:\/\/)?(www.)?soundcloud\.com\/\S*/) do |match|
        new_uri = match.to_s
        clean_url = new_uri.match(/(?i)\b((?:[a-z][\w-]+:(?:\/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))/)
        new_uri = (clean_url[0] =~ /^https?\:\/\/.*/) ? URI(clean_url[0]) : URI("https://#{clean_url[0]}")
        new_uri.normalize!
        links << "<iframe width='100%' height='166' scrolling='no' frameborder='no' src='https://w.soundcloud.com/player/?url=#{new_uri}'></iframe>"
      end
      return links.join(' ')
    rescue
    end
  end
end
