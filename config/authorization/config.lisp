;;;;;;;;;;;;;;;;;;;
;;; delta messenger
(in-package :delta-messenger)

;; (push (make-instance 'delta-logging-handler) *delta-handlers*)
(add-delta-messenger "http://deltanotifier/")


;;;;;;;;;;;;;;;;;
;;; configuration
(in-package :client)
(setf *log-sparql-query-roundtrip* nil) ;; disables query logging
(setf *backend* "http://virtuoso:8890/sparql")

(in-package :server)
(setf *log-incoming-requests-p* nil)

;; Keep long literals (> 4096 chars) in the triplestore instead of moving them
;; to files under /data/strings with an abbreviation URI in their place.
;; The harvesting graph is also written (nightly full harvest) and read
;; (publication graph healing, dumps) directly on virtuoso, bypassing this
;; service, so every reader must find the literal itself.
(in-package :support)
(setf *string-max-size* nil)

;;;;;;;;;;;;;;;;
;;; access rights

(type-cache::add-type-for-prefix "http://mu.semte.ch/sessions/" "http://mu.semte.ch/vocabularies/session/Session")

(in-package :acl)

(defparameter *access-specifications* nil
  "All known ACCESS specifications.")

(defparameter *graphs* nil
  "All known GRAPH-SPECIFICATION instances.")

(defparameter *rights* nil
  "All known GRANT instances connecting ACCESS-SPECIFICATION to GRAPH.")

(define-graph jobs ("http://mu.semte.ch/graphs/jobs")
  ("http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#FileDataObject" -> _)
  ("http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#RemoteDataObject" -> _)
  ("http://www.w3.org/ns/dcat#Dataset" -> _)
  ("http://www.w3.org/ns/dcat#Distribution" -> _)
  ("http://redpencil.data.gift/vocabularies/tasks/Task" -> _)
  ("http://vocab.deri.ie/cogs#Job" -> _)
  ("http://vocab.deri.ie/cogs#ScheduledJob" -> _)
  ("http://redpencil.data.gift/vocabularies/tasks/ScheduledTask" -> _)
  ("http://redpencil.data.gift/vocabularies/tasks/CronSchedule" -> _)
  ("http://schema.org/repeatFrequency" -> _)
  ("http://open-services.net/ns/core#Error" -> _)
  ("http://lblod.data.gift/vocabularies/harvesting/HarvestingCollection" -> _)
  ("http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#DataContainer" -> _)
  ("http://oscaf.sourceforge.net/ndo.html#DownloadEvent" -> _)
  ("http://www.w3.org/ns/dcat#Catalog" -> _)
  ("http://lblod.data.gift/vocabularies/security/AuthenticationConfiguration" -> _)
  ("http://lblod.data.gift/vocabularies/security/Credentials" -> _)
  ("http://lblod.data.gift/vocabularies/security/BasicAuthenticationCredentials" -> _)
  ("http://lblod.data.gift/vocabularies/security/OAuth2Credentials" -> _)
  ("https://www.w3.org/2019/wot/security#SecurityScheme" -> _)
  ("https://www.w3.org/2019/wot/security#BasicSecurityScheme" -> _)
  ("https://www.w3.org/2019/wot/security#OAuth2SecurityScheme" -> _))

(supply-allowed-group "authenticated"
  :parameters ()
  :query "PREFIX foaf: <http://xmlns.com/foaf/0.1/>
        PREFIX muAccount: <http://mu.semte.ch/vocabularies/account/>
        SELECT DISTINCT ?onlineAccount WHERE {

          VALUES ?accountPredicate {
            <http://mu.semte.ch/vocabularies/session/account>
            <http://mu.semte.ch/vocabularies/account/account>
          }

          <SESSION_ID> ?accountPredicate ?onlineAccount.

          ?onlineAccount a foaf:OnlineAccount.

          ?agent foaf:account ?onlineAccount.

          {
            <http://data.lblod.info/foaf/group/id/25e40ddc-0532-435d-a13f-7a2877cde5a7> foaf:member ?onlineAccount;
              foaf:name \"verenigingen\".

          } UNION {

            <http://data.lblod.info/foaf/group/id/25e40ddc-0532-435d-a13f-7a2877cde5a7> foaf:member ?agent;
              foaf:name \"verenigingen\".
          }
        }")

(grant (read write)
  :to-graph (jobs)
  :for-allowed-group "authenticated")
