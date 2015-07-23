import logging
import os
from oslo import i18n
i18n.enable_lazy()
from keystone import backends
from keystone.common import dependency
from keystone.common import environment
from keystone.common import sql
from keystone import config
from keystone.openstack.common import log
from keystone import service
CONF = config.CONF
config.configure()
sql.initialize()
config.set_default_for_default_log_levels()
CONF(project='keystone')
config.setup_logging()
environment.use_stdlib()
name = os.path.basename(__file__)
if CONF.debug:
    CONF.log_opt_values(log.getLogger(CONF.prog), logging.DEBUG)
drivers = backends.load_backends()
application = service.loadapp('config:%s' % config.find_paste_config(), name)
dependency.resolve_future_dependencies()
