(function($) {

  var skillsCt,
      skillsPath,
      skillPath,
      skillName,
      skillsList,
      skillNameSelector = '#skills-autocomplete .translated-name-row .current-language .translated-name-input';

  function getCloseSkills(query) {
    return $.ajax({
      headers: { Accept: "application/json" },
      url: skillsPath + window.encodeURIComponent(query)
    });
  }

  function getCloseSkillsSuccess(ct) {
    return function (skills) {
      ct.empty();
      $.each(skills, function(idx, skill) {
        var item = $('<li/>').appendTo(ct),
            link = $('<a/>', {
              href: skillPath + '/' + skill.id,
              target: '_blank',
              text: skill.translated_name
            }).appendTo(item),
            badge = $('<span/>', {
              'class': 'mat-badge-content mat-badge-active',
              text: skill.id
            }).appendTo(link);
        ct.show();
      });
    };
  }

  function getCloseSkillsError(ct) {
    return function (error) {
      ct.empty().hide();
    };
  }

  $(document)
    .on('input', skillNameSelector, function () {
      var input = $(this),
          query = $.trim(input.val());

      getCloseSkills(query).then(getCloseSkillsSuccess(skillsList), getCloseSkillsError(skillsList));
    })
    .on('turbolinks:load', function (e) {
      skillsCt = $('#skills-autocomplete');
      skillsPath = skillsCt.data('searchUrl');
      skillPath = skillsCt.data('itemUrl');
      skillName = $(skillNameSelector);
      skillsList = $('<ul/>', { 'class': 'skills-autocomplete-list'}).insertAfter(skillName).hide();
    });

}(jQuery));
