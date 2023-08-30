<?php

use yii\helpers\Html;
use yii\widgets\DetailView;
use yii\data\ArrayDataProvider;
use kartik\grid\GridView;
use yii\helpers\Url;

/* @var $this yii\web\View */
/* @var $model app\models\Countryy */

$this->title = 'Competition Detail : '. $model->title;
$this->params['breadcrumbs'][] = ['label' => 'Package', 'url' => ['index']];
$this->params['breadcrumbs'][] = $this->title;
//\yii\web\YiiAsset::register($this);
?>


<div class="row">
    <div class="col-xs-12">
        <div class="box">
            <!-- <div class="box-header">
                <h3 class="box-title"><?= Html::encode($this->title) ?></h3>

            </div>
             -->
            <div class="box-body">



    <p>
        <?= Html::a('Update', ['update', 'id' => $model->id], ['class' => 'btn btn-primary']) ?>
        
        <?= Html::a('Delete', ['delete', 'id' => $model->id], [
            'class' => 'btn btn-danger',
            'data' => [
                'confirm' => 'Are you sure you want to delete this item?',
                'method' => 'post',
            ],
        ]) ?>
    </p>

    <?= DetailView::widget([
        'model' => $model,
        'attributes' => [
            [
                'attribute'  => 'status',
                'value' => function($model){
                    return $model->statusButton;
                },
                'format'=>'raw'
                
            ],
            [
                'label'  => 'Competition Post',
                'value'  => function ($data) {
                    return count($data->post);
                },
                'format'=>'raw'
            ],
            'title',
            'start_date:datetime',
            'end_date:datetime',
            [
                'attribute'  => 'award_type',
                'value' => function($model){
                    return $model->awardTypeString;
                },
                'format'=>'raw'
                
            ],
            'price',
            'coin',
            'joining_fee',
            'winner_id',            
            
           // 'website',
          //  'last_active:datetime',
            'created_at:datetime',
            'updated_at:datetime',
            [
                'attribute'=>'image',
                'value'=> function ($model) {
                    // return Html::img($model->imageUrl, ['alt' => 'No Image', 'width' => '50px', 'height' => '50px']);
                },
                'format' => 'raw',
            ],
             [
                'attribute'=>'exampleFile',
                'value'=> function ($model) {
                    $imagesString='';
                    foreach($model->expampleImages as $photo){
                      //  $imagesString = $imagesString.' '.Html::img($photo->imageUrl, ['alt' => 'No Image', 'width' => '60px', 'height' => '60px']);   
                    }
                    return $imagesString;
                   
                },
                'format' => 'raw',
            ],

             [
                'attribute'=>'winner_id',
                'value'=> function ($model) {
                    if($model->winnerPost){
                        return Html::a(Html::img($model->winnerPost->imageUrl, ['alt' => 'No Image', 'width' => '50px', 'height' => '50px']),['post/view','id'=>$model->winnerPost->id]);
                    }else{
                        return 'Not awarded';
                    }
                     //return Html::img($model->winnerPost->imageUrl, ['alt' => 'No Image', 'width' => '50px', 'height' => '50px']);
                },
                'format' => 'raw',
            ],
            'description',            
        ],
    ]) ?>



        <?php echo '<br>';
               
                
               echo  GridView::widget([
                  'dataProvider' => new ArrayDataProvider([
                      'allModels' => $model->post,
                      'sort' => ['attributes' => [
                            'total_view',
                            'total_like',
                            'total_comment',
                            'popular_point' => [
                                'asc' => ['popular_point' => SORT_ASC],
                                'desc' => ['popular_point' => SORT_DESC],
                                'default' => SORT_DESC
                            ],  
                    
                        ],
                        'defaultOrder' => [
                            'popular_point' => SORT_DESC
                        ]
                    ]

                      
                  ]),
                  'rowOptions' => function ($model) {
                        if ($model->is_winning == 1) {
                            return ['class' => 'success'];
                        }
                    },
                 // 'filterModel' => $searchModel,
                  'columns' => [
                      //['class' => 'yii\grid\SerialColumn'],
                     // ['class' => 'kartik\grid\SerialColumn'],
                      
                       'title',
                       [
                           'attribute'  => 'user_id',
                           'value' => function($model){
                               
                               return Html::a($model->user->name, ['/user/view', 'id' => $model->user_id]);
                           },
                           'format'=>'raw'
                       ],
                     
                       'total_view',
                       'total_like',
                       'total_comment',
                       'popular_point',
                       
                       [
                           'attribute'  => 'status',
                           'value'  => function ($data) {
                               return $data->getStatus();
                           },
                       ],
                     
                      'created_at:datetime',
                        [
                           'class' => 'yii\grid\ActionColumn',
                            'header' => 'Action',
                            'template' => '{view}',
                            'urlCreator' => function ($action, $model, $key, $index) {
        
                                if ($action === 'view') {
                                    $url =     Url::to(['post/view','id'=>$model['id']]);
                                    return $url;

                                }


                            },

                        ],
                  
                  ],
                  'tableOptions' => [
                      'id' => 'theDatatable',
                      'class' => 'table table-striped table-bordered table-hover',
                  ],
                  'toolbar' => [
                  ],

                  'pjax' => false,
                  'bordered' => false,
                  'striped' => false,
                  'condensed' => false,
                  'responsive' => true,
                  'hover' => true,
                  'floatHeader' => false,
                  //'floatHeaderOptions' => ['top' => $scrollingTop],
                  'showPageSummary' => false,
                  'summary'=> false,
                  
                  'panel' => [
                      'type' => GridView::TYPE_PRIMARY,
                      'heading'=>'Competition User post',
                      //'footer'=>'Totoal Price : '.$model->slotBookingAmount
                      
                  ],
                                 
              ]); 
             
              ?>
             

</div>


</div>

</div>
</div>
