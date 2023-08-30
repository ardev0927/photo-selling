<?php
namespace api\modules\v1\models;
use Yii;
use api\modules\v1\models\Competition;
use yii\base\Model;
use yii\data\ActiveDataProvider;
use yii\db\Expression;

class CompetitionSearch extends Competition
{
    
    /**
     * {@inheritdoc}
     */
    public function rules()
    {
        return [
            [['title'], 'string']
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
    
    /**
     * search post
     */

    public function search($params)
    {
        
        
        $this->load($params,'');

        
        $query = Competition::find()
        ->select(['competition.id','competition.title','competition.description','competition.start_date','competition.end_date','competition.award_type','competition.price','competition.coin','competition.joining_fee','competition.winner_id','competition.image','competition.status','competition.created_at'])
        ->where(['<>','competition.status',Competition::STATUS_DELETED])
        //->orderBy(['Competition.name'=>SORT_ASC]);
        ->joinWith(['post' => function($query){
            $query->select(['id','type','competition_id','user_id','title','image','total_view','total_like','total_comment','total_share','popular_point','status','created_at']);
             
        }])
        ->joinWith(['post.user' => function($query){
            $query->select(['id','name','email','bio','description','image','country_code','phone','country','city','sex']);
             
        }])
        ->joinWith(['winnerPost' => function($query){
            $query->select(['id','type','competition_id','user_id','title','image','total_view','total_like','total_comment','total_share','popular_point','status','created_at']);
             
        }])
        ->joinWith(['winnerPost.user' => function($query){
            $query->select(['id','name','email','bio','description','image','country_code','phone','country','city','sex']);
             
        }]);
        
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
         /*$query->andFilterWhere([
            'category_id' => $this->category_id,
        ]);*/
        $query->andFilterWhere(['like', 'title', $this->title]);
        //$query->andFilterWhere(['like', 'artist', $this->name]);

      

        return $dataProvider;
    }

    public function searchMyCompetition($params)
    {
        $userId                 = Yii::$app->user->identity->id;
        $this->load($params,'');

        
        $query = Competition::find()
        ->select(['competition.id','competition.title','competition.start_date','competition.end_date','competition.award_type','competition.price','competition.coin','competition.joining_fee','competition.winner_id','competition.image','competition.status','competition.created_at'])
        ->where(['<>','competition.status',Competition::STATUS_DELETED])
        //->orderBy(['Competition.name'=>SORT_ASC]);
        ->joinWith(['post' => function($query){
            $query->select(['id','type','competition_id','user_id','title','image','total_view','total_like','total_comment','total_share','popular_point','status','created_at']);
             
        }])
        ->joinWith(['post.user' => function($query){
            $query->select(['name','image','id']);
             
        }])
        ->joinWith('competitionUser');
             
        
        /*->joinWith(['competitionUser' => function($query){
            $query->select(['id','competition_id','user_id','is_winner']);
             
        }])
       
        ->joinWith(['competitionUser.userDetail' => function($query){
            $query->select(['name','image','id']);
             
        }])
        ->joinWith(['competitionUser.post' => function($query){
            $query->select(['id','type','user_id','competition_id','title','image']);
             
        }]);*/
        
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
         $query->andFilterWhere([
            'competition_user.user_id' => $userId,
        ]);
        $query->andFilterWhere(['like', 'title', $this->title]);
        //$query->andFilterWhere(['like', 'artist', $this->name]);

      

        return $dataProvider;
    }

    
}
