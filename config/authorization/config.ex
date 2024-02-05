alias Acl.Accessibility.Always, as: AlwaysAccessible
alias Acl.GraphSpec.Constraint.Resource, as: ResourceConstraint
alias Acl.GraphSpec, as: GraphSpec
alias Acl.GroupSpec, as: GroupSpec
alias Acl.GroupSpec.GraphCleanup, as: GraphCleanup
alias Acl.Accessibility.ByQuery, as: AccessByQuery

defmodule Acl.UserGroups.Config do
  defp logged_in_user() do
    %AccessByQuery{
      vars: [],
      query: "PREFIX session: <http://mu.semte.ch/vocabularies/session/>
      SELECT DISTINCT ?account WHERE {
      <SESSION_ID> session:account ?account.
      }"
    }
  end

  def user_groups do
    [
      # Harvesting
      %GroupSpec{
        name: "harvesting",
        useage: [:write, :read_for_write, :read],
        access: logged_in_user(),
        graphs: [ %GraphSpec{
                    graph: "http://mu.semte.ch/graphs/harvesting",
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

      # Allow access to (public) harvesting config for delta consumers
      # Note this allows access to all data to data in the harvesting graph and not just the listed types
      # being able to read this is consider OK for, but we should set up authenticated delta's later on
      %GroupSpec{
        name: "harvesting-public",
        useage: [:read],
        access: %AlwaysAccessible{},
        graphs: [
          %GraphSpec{
            graph: "http://mu.semte.ch/graphs/harvesting",
            constraint: %ResourceConstraint{
              resource_types: [
                "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#RemoteDataObject",
                "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#FileDataObject",
              ]
            }
          }
        ]
      },

      # Allow access to (public) scraped data
      # Note this allows access to all data to data in the public graph and not just the listed types
      # This behaviour may change in the future as mu-auth evolves
      %GroupSpec{
        name: "public",
        useage: [:read],
        access: %AlwaysAccessible{},
        graphs: [
          %GraphSpec{
                    graph: "http://mu.semte.ch/graphs/public",
                    constraint: %ResourceConstraint{
                      resource_types: [
                        "http://data.vlaanderen.be/ns/besluit#Besluit",
                        "http://data.vlaanderen.be/ns/besluit#Zitting",
                        "http://data.vlaanderen.be/ns/besluit#Bestuursorgaan",
                        "http://xmlns.com/foaf/0.1/Document",
                        "http://data.vlaanderen.be/ns/besluit#Agendapunt",
                        "http://www.w3.org/2004/02/skos/core#Concept",
                        "http://purl.org/dc/terms/Agent",
                        "http://data.vlaanderen.be/ns/besluit#Artikel",
                        "http://data.vlaanderen.be/ns/besluit#BehandelingVanAgendapunt",
                        "http://data.vlaanderen.be/ns/besluit#Bestuurseenheid",
                        "https://data.vlaanderen.be/ns/generiek#DocumentOnderdeel",
                        "http://data.europa.eu/eli/ontology#LegalExpression",
                        "http://data.vlaanderen.be/ns/mandaat#Mandataris",
                        "http://data.europa.eu/eli/ontology#LegalResource",
                        "http://data.europa.eu/eli/ontology#LegalResourceSubdivision",
                        "http://data.vlaanderen.be/ns/besluit#Stemming",
                        "http://data.vlaanderen.be/ns/besluit#Vergaderactiviteit",
                        "http://data.vlaanderen.be/ns/mandaat#Mandaat",
                        "http://www.w3.org/ns/person#Person"
                      ]
                    }
          }
        ]
      },
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
