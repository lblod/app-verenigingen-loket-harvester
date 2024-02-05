    (in-package :mu-cl-resources)

(defparameter *cache-count-queries* nil)
(defparameter *supply-cache-headers-p* t
  "when non-nil, cache headers are supplied.  this works together with mu-cache.")
(setf *cache-model-properties-p* t)
(defparameter *include-count-in-paginated-responses* t
  "when non-nil, all paginated listings will contain the number
   of responses in the result object's meta.")
(defparameter *max-group-sorted-properties* t)
(defparameter sparql:*experimental-no-application-graph-for-sudo-select-queries* t)

(read-domain-file "master-harvest-domain.lisp")
(read-domain-file "master-file-domain.lisp")
(read-domain-file "master-job-domain.lisp")
(read-domain-file "master-scheduled-domain.lisp")
(read-domain-file "dcat.json")
