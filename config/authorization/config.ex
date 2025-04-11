alias Acl.Accessibility.Always, as: AlwaysAccessible
alias Acl.GraphSpec.Constraint.Resource, as: ResourceConstraint
alias Acl.GraphSpec, as: GraphSpec
alias Acl.GroupSpec, as: GroupSpec
alias Acl.GroupSpec.GraphCleanup, as: GraphCleanup
alias Acl.Accessibility.ByQuery, as: AccessByQuery

defmodule Acl.UserGroups.Config do

  defp can_access_verenigingen_data() do
    %AccessByQuery{
      vars: [ ],
      query: "
        PREFIX foaf: <http://xmlns.com/foaf/0.1/>
        PREFIX muAccount: <http://mu.semte.ch/vocabularies/account/>
        SELECT DISTINCT ?onlineAccount WHERE {
          <SESSION_ID> <http://mu.semte.ch/vocabularies/session/account> ?onlineAccount.

          ?onlineAccount a foaf:OnlineAccount.

          <http://data.lblod.info/foaf/group/id/25e40ddc-0532-435d-a13f-7a2877cde5a7> foaf:member ?onlineAccount;
            foaf:name \"verenigingen\".
        }"
      }
  end

  def user_groups do
    [
        %GroupSpec{
          name: "o-verenigingen-rwf",
          useage: [:read, :write, :read_for_write],
          access: can_access_verenigingen_data(),
          graphs: [ %GraphSpec{
                      graph: "http://mu.semte.ch/graphs/jobs",
                      constraint: %ResourceConstraint{
                        resource_types: [
                          "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#FileDataObject",
                          "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#RemoteDataObject",
                          "http://www.w3.org/ns/dcat#Dataset", # is needed in dump file
                          "http://www.w3.org/ns/dcat#Distribution",
                        ] } } ] },
      # Harvesting
      %GroupSpec{
        name: "harvesting",
        useage: [:write, :read_for_write, :read],
        access: can_access_verenigingen_data(),
        # access: %AlwaysAccessible{},
        graphs: [ %GraphSpec{
                    graph: "http://mu.semte.ch/graphs/jobs",
                    constraint: %ResourceConstraint{
                      resource_types: [
                        "http://redpencil.data.gift/vocabularies/tasks/Task",
                        "http://vocab.deri.ie/cogs#Job",
                        "http://vocab.deri.ie/cogs#ScheduledJob",
                        "http://redpencil.data.gift/vocabularies/tasks/ScheduledTask",
                        "http://redpencil.data.gift/vocabularies/tasks/CronSchedule",
                        "http://schema.org/repeatFrequency",
                        "http://open-services.net/ns/core#Error",
                        "http://lblod.data.gift/vocabularies/harvesting/HarvestingCollection",
                        "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#RemoteDataObject",
                        "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#FileDataObject",
                        "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#DataContainer",
                        "http://oscaf.sourceforge.net/ndo.html#DownloadEvent",
                        "http://www.w3.org/ns/dcat#Dataset",
                        "http://www.w3.org/ns/dcat#Distribution",
                        "http://www.w3.org/ns/dcat#Catalog",
                        "http://lblod.data.gift/vocabularies/security/AuthenticationConfiguration",
                        "http://lblod.data.gift/vocabularies/security/Credentials",
                        "http://lblod.data.gift/vocabularies/security/BasicAuthenticationCredentials",
                        "http://lblod.data.gift/vocabularies/security/OAuth2Credentials",
                        "https://www.w3.org/2019/wot/security#SecurityScheme",
                        "https://www.w3.org/2019/wot/security#BasicSecurityScheme",
                        "https://www.w3.org/2019/wot/security#OAuth2SecurityScheme"
                      ]
                    } } ] },
      # CLEANUP
      #
      %GraphCleanup{
        originating_graph: "http://mu.semte.ch/application",
        useage: [:write],
        name: "clean"
      }
    ]
  end
end
