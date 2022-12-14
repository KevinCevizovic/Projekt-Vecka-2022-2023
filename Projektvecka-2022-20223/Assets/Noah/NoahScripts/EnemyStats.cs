using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyStats : CharacterStats
{
    public override void Dead()
    {
        if(CurrentHealth <= 0)
        {
            base.Dead();
            Destroy(gameObject);
            print("Enemy dead");
        }
    }
}
