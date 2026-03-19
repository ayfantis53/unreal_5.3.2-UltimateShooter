// Fill out your copyright notice in the Description page of Project Settings.


#include "Pawns/US_Tower_base.h"

// Sets default values
AUS_Tower_base::AUS_Tower_base()
{
 	// Set this pawn to call Tick() every frame.  You can turn this off to improve performance if you don't need it.
	PrimaryActorTick.bCanEverTick = true;

}

// Called when the game starts or when spawned
void AUS_Tower_base::BeginPlay()
{
	Super::BeginPlay();
	
}

// Called every frame
void AUS_Tower_base::Tick(float DeltaTime)
{
	Super::Tick(DeltaTime);

}

// Called to bind functionality to input
void AUS_Tower_base::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
	Super::SetupPlayerInputComponent(PlayerInputComponent);

}

