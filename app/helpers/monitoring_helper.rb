module MonitoringHelper

=begin
  def list
    @skills = Skill.joins(concepts_list).select(concepts_list_output)
  end
=end

  ### extract object's series for d3

  def skills_by_theme_series
    theme_series = DefinedSkill.joins(concepts_list).
                         select(themes[:code].as("themes_code"), themes_names[:translation].as("themes_name"), defined_skills[:id].count.as("count")).
                         group("themes_code", "themes_name")
  end

  def skills_by_user_series
    user_series = DefinedSkill.joins(concepts_list).
                        select(users[:user_name].as("users_code"), users[:name].as("users_name"), defined_skills[:id].count.as("count")).
                        group("users_code", "users_name")
  end

  def skills_by_week_series
    week_series = DefinedSkill.joins(concepts_list).
                        select(Arel::Nodes::NamedFunction.new('DATE_PART', [Arel::Nodes.build_quoted('week'), defined_skills[:created_at]]).as("week"), defined_skills[:id].count.as("count")).
                        group("week").
                        order("week")
  end

  def skills_by_day_series
    dayly_series = DefinedSkill.joins(concepts_list).
                         select(defined_skills[:created_at].as("day"), defined_skills[:id].count.as("count")).
                         group("day").
                         order("day")
  end

  def top_concepts_series
    top_series = DefinedSkill.joins(templates_list).
                       select(defined_skills[:id], defined_skills[:status_id], defined_skills[:code], defined_skills[:updated_at], defined_skills[:updated_by], used_skills[:id].count.as("count")).
                       group(defined_skills[:id], defined_skills[:status_id], defined_skills[:code], defined_skills[:updated_at], defined_skills[:updated_by]).having(used_skills[:id].count.gt(0)).
                       order(used_skills[:id].count.desc).
                       take(10)
  end

  def flop_concepts_series
    flop_series = DefinedSkill.joins(templates_list).
                        select(defined_skills[:id], defined_skills[:status_id], defined_skills[:code], defined_skills[:updated_at], defined_skills[:updated_by], "0 as Count").
                        where(used_skills[:id].eq(nil)).
                        order(defined_skills[:updated_at]).
                        take(10)
  end

#######################################################
  private
    def defined_skills
      DefinedSkill.arel_table
    end

    def used_skills
      DeployedSkill.arel_table.alias('used_skills')
    end
    ### Monitoring queries
    # Additional tables
    def users
      User.arel_table
    end

    def organisations
      Organisation.arel_table
    end

    def themes
      Playground.arel_table.alias('themes')
    end

    def domains
      BusinessArea.arel_table.alias('domains')
    end

    def collections
      DefinedObject.arel_table.alias('collections')
    end

    def timeline
      DimTime.arel_table
    end

    def themes_names
      Translation.arel_table.alias('themes_names')
    end

    def domains_names
      Translation.arel_table.alias('domains_names')
    end

    def organisations_names
      Translation.arel_table.alias('organisations_names')
    end

    # Queries
    def concepts_list
      defined_skills.
      join(users).on(defined_skills[:owner_id].eq(users[:id])).
      join(organisations).on(defined_skills[:organisation_id].eq(organisations[:id])).
      join(collections).on(defined_skills[:business_object_id].eq(collections[:id])).
      join(domains).on(collections[:parent_id].eq(domains[:id]).and(collections[:parent_type].eq('BusinessArea'))).
      join(themes).on(domains[:playground_id].eq(themes[:id])).
      join(themes_names, Arel::Nodes::OuterJoin).on(themes[:id].eq(themes_names[:document_id]).and(themes_names[:document_type].eq("Playground")).and(themes_names[:language].eq(current_language).and(themes_names[:field_name].eq('name')))).
      join(domains_names, Arel::Nodes::OuterJoin).on(domains[:id].eq(domains_names[:document_id]).and(domains_names[:document_type].eq("BusinessArea")).and(domains_names[:language].eq(current_language).and(domains_names[:field_name].eq('name')))).
      join(organisations_names, Arel::Nodes::OuterJoin).on(organisations[:id].eq(organisations_names[:document_id]).and(organisations_names[:document_type].eq("Organisation")).and(organisations_names[:language].eq(current_language).and(organisations_names[:field_name].eq('name')))).
      join_sources
    end

    def templates_list
      defined_skills.
      join(used_skills, Arel::Nodes::OuterJoin).on(defined_skills[:id].eq(used_skills[:template_skill_id])).where(defined_skills[:is_template].eq(true)).
      join_sources
    end

    def concepts_list_output
      [defined_skills[:id], defined_skills[:created_at], users[:user_name], users[:name],
      organisations[:code], organisations_names[:translation].as("organisations_name"),
      themes[:code], themes_names[:translation].as("themes_name"),
      domains[:code], domains_names[:translation].as("domains_name"), defined_skills[:created_at]
    ]
    end
#######################################################

end
