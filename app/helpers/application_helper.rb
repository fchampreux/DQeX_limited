module ApplicationHelper

### Implementing Help files management with Markdown
  def markdown
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true, tables: true)
  end

  def displayHelp
    case params[:page_name]
    when 'Change_Log'
      filename = File.join(Rails.root, 'public', "CHANGELOG.md")
    when 'Release_notes'
      filename = File.join(Rails.root, 'public', "Release_notes.md")
    else
      filename = File.join(Rails.root, 'public', "help-#{I18n.locale.to_s[0,2]}", "#{params[:page_name]}.md")
    end

    if not File.file?(filename)
      filename = File.join(Rails.root, 'public', "help-#{I18n.locale.to_s[0,2]}", "help-index.md")
    end

    begin
      file = File.open(filename, "rb")
      markdown.render(file.read).html_safe.force_encoding('UTF-8')
    rescue Errno::ENOENT
      render :file => "public/404.html", :status => 404
    end
  end

### Features management
  def version_management
    return $Versionning
  end

end
