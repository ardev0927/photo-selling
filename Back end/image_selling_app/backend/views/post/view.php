<?php

use yii\helpers\Html;
use yii\widgets\DetailView;
use yii\grid\GridView;
use yii\data\ArrayDataProvider;
/* @var $this yii\web\View */
/* @var $model app\models\Countryy */

$this->title = 'Post Detail';

//$this->title = 'Ad Detail';
$this->params['breadcrumbs'][] = ['label' => 'post', 'url' => ['index']];
$this->params['breadcrumbs'][] = $this->title;
\yii\web\YiiAsset::register($this);

?>


<div class="row">
    <div class="col-xs-12">
        <div class="box">

            <div class="box-body">



                <p>
                    
                    <?php
                    if ($model->status == $model::STATUS_ACTIVE) {
                        echo Html::a('Block Post', ['update-status', 'id' => $model->id, 'type' => 'block'], ['class' => 'btn btn-danger']);
                    } else if ($model->status == $model::STATUS_BLOCKED) {
                        echo Html::a('Reactive Post', ['update-status', 'id' => $model->id, 'type' => 'active'], ['class' => 'btn btn-success']);
                        //echo '&nbsp;';

                    }
                    echo '&nbsp;';

                    if ($model->type == $model::TYPE_COMPETITION) {
                        

                        echo Html::a('View Competition', ['competition/view', 'id' => $model->competition->id], ['class' => 'btn btn-primary']);
                        echo '&nbsp;';
                       
                        if($model->competition->status == $model->competition::STATUS_ACTIVE){

                            $currentTime= time();
                            if($model->competition->end_date < $currentTime){

                                echo  Html::a('Make this image Winner', ['competition/winning', 'id' => $model->id], [
                                    'class' => 'btn btn-success',
                                    'data' => [
                                        'confirm' => 'Are you sure you want award winning this image?',
                                        'method' => 'post',
                                    ],
                                ]); 
                            }
                            //echo Html::a('Make Winning Competition', ['update-status', 'id' => $model->id, 'type' => 'block'], ['class' => 'btn btn-success']);
                        }
                        echo '&nbsp;';
                        if($model->competition->winner_id == $model->id){
                            echo '<span class="label label-success">Competition Winner Image</span>';
                        }


                    } 

                    ?>
                </p>


                <div class="col-xs-6" style="padding:0px;">

                    <?=DetailView::widget([
                    'model' => $model,
                    'attributes' => [
                        'title',
                        [
                            'attribute' => 'status',
                            'value' => function ($model) {
                                return $model->getStatus();
                            },

                        ],
                        'total_view',
                        'total_like',
                        'popular_point',
                        'total_comment',
                        [
                            'attribute' => 'User',
                            'value' => function ($model) {

                                return Html::a($model->user->name, ['/user/view', 'id' => $model->user_id]);
                            },
                            'format' => 'raw',
                        ],
                        'created_at:datetime',

                    ],
                ])?>
                </div>
                <div class="col-xs-6">

                
                 <?php 
               
                 echo  Html::img($model->imageUrl, ['alt' => 'No Image' ]);?>

                  


                </div>
                
                <div class="box-header col-xs-12">
                    <h3 class="box-title">Comments</h3>

                </div>

                <?php 
                
                
                echo  GridView::widget([
                   'dataProvider' => new ArrayDataProvider([
                       'allModels' => $model->postComment,
                       'pagination' => [
                        'pageSize' => 40,
                        ]
                   ]),
                  // 'filterModel' => $searchModel,
                   'columns' => [
                       ['class' => 'yii\grid\SerialColumn',
                       'headerOptions' => ['style' => 'width:5%']
                    
                        ],
                       //['class' => 'kartik\grid\SerialColumn'],
                       [
                           'attribute' => 'user_id',
                           'headerOptions' => ['style' => 'width:15%'],
                           'value' => function ($model) {
                               return Html::a($model->user['username'], ['/user/view', 'id' => $model->user['id']]);
                            },
                           'format'=>'raw'
                       ],
                       [
                            'attribute' => 'created_at',
                            'headerOptions' => ['style' => 'width:15%'],
                             'value' => 'created_at',
                             'format'=>'datetime'
                        
                        ],
                    
                       'comment',
                       
                       
                   
                   ],
                   'tableOptions' => [
                       'id' => 'theDatatable',
                       'class' => 'table table-striped table-bordered table-hover',
                   ],
                   'summary'=> false,
                   
                   
                                  
               ]); ?>
            


            </div>

        </div>

    </div>