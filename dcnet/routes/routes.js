const { Router } = require('express');
const controller = require('../controllers/controller');
const cookies = require('../cookies/cookies');

const router = Router();

router.get  ('/login'   , controller.login_get      );
router.post ('/login'   , controller.login_post     );
router.get  ('/logout'  , controller.logout_get     );
router.get  ('/cadastro', controller.cadastro_get   );
router.post ('/cadastro', controller.cadastro_post  );
router.get  ('*'        , cookies.verificarLogin, controller.adicionar_nome);
router.post ('*'        , cookies.verificarLogin, controller.adicionar_nome);
router.get  ('/inicio'  , controller.inicio_get         );
router.get  ('/perfil'  , controller.perfil_get         );
router.post ('/perfil'  , controller.perfil_post        );
router.get  ('/amigos'  , controller.amigos_get         );
router.post ('/amigos'  , controller.amigos_post        );
router.get  ('*'        , controller.redirecionar_inicio);
router.post ('*'        , controller.redirecionar_inicio);

module.exports = router;