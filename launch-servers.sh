#!/bin/bash
(dart web/server/authserver.dart & )
(dart web/server/queryserver.dart &)
(dart web/server/dataserver.dart &)

