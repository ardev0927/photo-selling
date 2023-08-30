<?php
namespace backend\controllers;

use app\models\User;
use backend\models\Ad;
use common\models\LoginForm;
use common\models\Payment;
use common\models\Post;
use common\models\PostComment;
use common\models\Audio;
use common\models\Competition;
use Yii;
use yii\filters\AccessControl;
use yii\filters\VerbFilter;
use yii\web\Controller;

/**
 * Site controller
 */
class SiteController extends Controller
{
    /**
     * {@inheritdoc}
     */
    public function behaviors()
    {
        return [
            'access' => [
                'class' => AccessControl::className(),
                'rules' => [
                    [
                        'actions' => ['login', 'error'],
                        'allow' => true,
                    ],
                    [
                        'actions' => ['logout', 'index'],
                        'allow' => true,
                        'roles' => ['@'],
                    ],
                ],
            ],
            'verbs' => [
                'class' => VerbFilter::className(),
                'actions' => [
                    'logout' => ['post'],
                ],
            ],
        ];
    }

    /**
     * {@inheritdoc}
     */
    public function actions()
    {
        return [
            'error' => [
                'class' => 'yii\web\ErrorAction',
            ],
        ];
    }

    /**
     * Displays homepage.
     *
     * @return string
     */
    public function actionIndex()
    {
        $modelAd = new Ad();
        
        $modelPost = new Post();
        $modelPostComment = new PostComment();
        $modelAudio = new Audio();
        
        $modelUser = new User();
        $modelPayment = new Payment();
        $modelCompetition = new Competition();

       // $activeJob = $modelAd->getActiveJobCount();
        $totalPost = $modelPost->getTotalPostCount();
        $totalComment = $modelPostComment->getTotalCommetCount();
        $totalAudio = $modelAudio->getTotalAudioCount();
        
        //$pendingJobCount = $modelAd->getPendingJobCount();
        //$totalEarning = $modelPayment->getTotalEarning();
        //$totalEarning = round($totalEarning);

        $userCount = $modelUser->getUserCount();
        $competitionCount = $modelCompetition->getCompetitionCount();




       
        $firstGraph = $modelPost->getLastTweleveMonthPost();

        $paymentGraph = $modelUser->getLastTweleveMonthUser();

        //print_r($paymentGraph);

        // print_r($activeJob);

        return $this->render('index', [
            'totalPost' => $totalPost,
            'totalComment' => $totalComment,
            'userCount' => $userCount,
            'totalCompetition' => $competitionCount,
            'firstGraph' => $firstGraph,
            'paymentGraph' => $paymentGraph,

        ]);

    }

    /**
     * Login action.
     *
     * @return string
     */
    public function actionLogin()
    {

        if (!Yii::$app->user->isGuest) {
            return $this->goHome();
        }
        $model = new LoginForm();

        if (isset($_COOKIE["username"]) && isset($_COOKIE["password"])) {

            $username = $_COOKIE["username"];
            $password = $_COOKIE["password"];

        } else {

            $username = null;
            $password = null;
        }

        if ($model->load(Yii::$app->request->post())) {

            $user = User::findByUsername($model->username);

            $data = Yii::$app->request->post();
            if ($user) {
                if ($user->role == User::ROLE_ADMIN || $user->role == User::ROLE_SUBADMIN) {

                    if ($model->login()) {
                        $user->last_active = time();
                        $user->save(false);
                        //echo 'loogged';
                        //die;
                        //echo '<pre>'; print_r($data['LoginForm']); exit;
                        if ($data['LoginForm']['rememberMe'] == 1) {
                            $hour = time() + 3600 * 24 * 30;
                            setcookie('username', $data['LoginForm']['username'], $hour);
                            setcookie('password', $data['LoginForm']['password'], $hour);
                        }
                        //    Yii::$app->session->setFlash('success',  'You have sussessfull loggedin');
                        return $this->goBack();
                    } else {

                        Yii::$app->session->setFlash('warning', "Invalid Data.");
                        return $this->goBack();
                    }
                } else {
                    Yii::$app->session->setFlash('warning', "Invalid Data.");
                    return $this->goBack();

                }
            } else {
                Yii::$app->session->setFlash('warning', "Invalid Data.");
                return $this->goBack();
            }

        } else {
            $model->password = '';

            return $this->render('login', [
                'model' => $model,
                'username' => $username,
                'password' => $password,
            ]);
        }

    }

    /**
     * Logout action.
     *
     * @return string
     */
    public function actionLogout()
    {
        Yii::$app->user->logout();

        return $this->goHome();
    }
}
