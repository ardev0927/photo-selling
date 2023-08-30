<?php
namespace api\modules\v1\models;
use Yii;
use api\modules\v1\models\Post;
use yii\base\Model;
use yii\data\ActiveDataProvider;
use yii\db\Expression;

class PostSearch extends Post
{
    
    public $is_popular_post;
    public $is_following_user_post;
    public $is_my_post;
    public $is_winning_post;
    /**
     * {@inheritdoc}
     */
    public function rules()
    {
        return [
            [['hashtag'], 'string'],
            [['user_id','is_popular_post','is_following_user_post','is_my_post','is_winning_post'], 'integer'],
          //  [['title'], 'safe'],
        ];
    }

    /**
     * {@inheritdoc}
     */
    public function scenarios()
    {
        // bypass scenarios() implementation in the parent class
          return Model::scenarios();
    }

    /**
     * Creates data provider instance with search query applied
     *
     * @param array $params
     *
     * @return ActiveDataProvider
     */
    public function searchMyPost($params)
    {
        $userId   =  Yii::$app->user->identity->id;
        $query = Post::find()
       
        ->select(['post.id','post.type','post.user_id','post.title','post.competition_id','post.image','post.total_view','post.total_like','post.total_comment','post.total_share','post.popular_point','post.status','post.created_at'])
        ->where(['post.user_id'=>$userId])
        ->andWhere(['<>','post.status',Post::STATUS_DELETED])
        ->orderBy(['post.id'=>SORT_DESC]);
        $dataProvider = new ActiveDataProvider([
            'query' => $query,
            'pagination' => [
                'pageSize' => 20,
            ]
        ]);

      //  $this->load($params);

        $this->setAttributes($params);

        if (!$this->validate()) {
            // uncomment the following line if you do not want to return any records when validation fails
            // $query->where('0=1');
            return $dataProvider;
        }
       
        // grid filtering conditions
         $query->andFilterWhere([
            //'ad.user_id' => $this->user_id,
           //  'hash_tag.hashtag' => $this->hashtag,
            
            
        ]);

      
        return $dataProvider;
    }

    /**
     * search post
     */

    public function search($params)
    {
        $userId   =  Yii::$app->user->identity->id;
       // $countryId   =  Yii::$app->user->identity->country_id;
        
        $isFilter=false;
        $this->load($params,'');

        if($this->user_id || $this->hashtag || $this->is_following_user_post ){ /// for whether within country or overall
            $isFilter=true; /// overall
        }

        
        
        $query = Post::find()
        ->select(['post.id','post.type','post.user_id','post.title','post.competition_id','post.is_winning','post.image','post.total_view','post.total_like','post.total_comment','post.total_share','post.popular_point','post.status','post.created_at'])
        ->joinWith(['user' => function($query) use ($isFilter){
            $query->select(['name','email','image','id']);
        }])
        ->joinWith('hashtags')
        ->where(['<>','post.status',Post::STATUS_DELETED])
        //->orderBy(['post.id'=>SORT_DESC]);
        ->orderBy(new Expression('rand()'));

        if($this->is_popular_post){
            $popuplarPointCondition = Yii::$app->params['postPopularityPoint']['popuplarPointCondition'];
            $query->andWhere(['>','post.popular_point',$popuplarPointCondition]);

        }
        if($this->is_following_user_post){

            $query->joinWith(['followers' => function($query) use ($userId){
               //$query->where(['follower_id'=>$userId]);
              
            }]);
            //$query->andWhere(['follower.follower_id'=>$userId]);
            if($this->is_my_post){
                $query->andWhere(
                    ['or',
                        
                        ['follower.follower_id'=>$userId],
                        ['post.user_id'=>$userId]
                        
                    ]);
            
            }else{
                $query->andWhere(['follower.follower_id'=>$userId]);
            }
            


        }else{
            if($this->is_my_post){
                $query->andWhere(['post.user_id'=>$userId]);
            }

        }
       // if()

        /*if($this->user_id){

            $query->andFilterWhere([
                'post.user_id' => $this->user_id
                
            ]);

        }else{

        }
*/


        $query->distinct();


        $dataProvider = new ActiveDataProvider([
            'query' => $query,
            'pagination' => [
                'pageSize' => 20,
            ]
        ]);
        
      //  $this->setAttributes($params);
        if (!$this->validate()) {
            // uncomment the following line if you do not want to return any records when validation fails
            // $query->where('0=1');
            return $dataProvider;
        }
        // grid filtering conditions
        if($this->is_winning_post){
            $query->andFilterWhere([
                'post.is_winning' => $this->is_winning_post,
            ]);   
        }
         $query->andFilterWhere([
            'post.user_id' => $this->user_id,
             'hash_tag.hashtag' => $this->hashtag
        ]);
        return $dataProvider;
    }
    
    
}
