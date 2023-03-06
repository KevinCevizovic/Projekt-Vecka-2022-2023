using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class PartisanAttacks : MonoBehaviour
{
    private Animator anim;
    public float cooldownTime = 2f;
    private float nextFireTime = 0f;
    public static int noOfClicks = 0;
    float lastClickedTime = 1;
    float maxComboDelay = 1;

    public float chargeTime;
    public float chargedDamage;
    private bool isCharging = false;

    public float damage;

    private void Start()
    {
        anim = GetComponent<Animator>();
    }

    void Update()
    {
        bool noahVet = anim.GetCurrentAnimatorStateInfo(0).normalizedTime > 0.7f;

        if (noahVet && anim.GetCurrentAnimatorStateInfo(0).IsName("Combo1"))
        {
            anim.SetBool("Combo1", false);
        }
        if (noahVet && anim.GetCurrentAnimatorStateInfo(0).IsName("Combo2"))
        {
            anim.SetBool("Combo2", false);
        }
        if (noahVet && anim.GetCurrentAnimatorStateInfo(0).IsName("Combo3"))
        {
            anim.SetBool("Combo3", false);
            noOfClicks = 0;
        }
        if (noahVet && anim.GetCurrentAnimatorStateInfo(0).IsName("HeavyCombo1"))
        {
            anim.SetBool("HeavyCombo1", false);
        }
        if (noahVet && anim.GetCurrentAnimatorStateInfo(0).IsName("HeavyCombo2"))
        {
            anim.SetBool("HeavyCombo2", false);
            anim.SetBool("HeavyCombo1", false);
            noOfClicks = 0;
        }


        if (Time.time - lastClickedTime > maxComboDelay)
        {
            noOfClicks = 0;
        }

        if (Mouse.current.rightButton.wasReleasedThisFrame && !isCharging && anim.GetCurrentAnimatorStateInfo(0).normalizedTime > 0.7f)
        {
            anim.SetBool("HeavyCombo1", false);
            anim.SetBool("HeavyCombo2", true);
        }
    }

    public void RightClick()
    {
        if (Time.time <= nextFireTime) return;

        anim.SetBool("HeavyCombo2", false);
        anim.SetBool("HeavyCombo1", true);
        StartCoroutine(ChargedAttack());
    }

    public void LeftClick()
    {
        if (Time.time <= nextFireTime) return;
        //so it looks at how many clicks have been made and if one animation has finished playing starts another one.

        lastClickedTime = Time.time;
        noOfClicks++;
        if (noOfClicks == 1)
        {
            anim.SetBool("Combo1", true);
            anim.SetBool("Combo2", false);
            anim.SetBool("Combo3", false);
        }
        noOfClicks = Mathf.Clamp(noOfClicks, 0, 3);

        if (noOfClicks >= 2 && anim.GetCurrentAnimatorStateInfo(0).normalizedTime > 0.7f && anim.GetCurrentAnimatorStateInfo(0).IsName("Combo1"))
        {
            anim.SetBool("Combo1", false);
            anim.SetBool("Combo2", true);
        }
        if (noOfClicks >= 3 && anim.GetCurrentAnimatorStateInfo(0).normalizedTime > 0.7f && anim.GetCurrentAnimatorStateInfo(0).IsName("Combo2"))
        {
            anim.SetBool("Combo2", true);
            anim.SetBool("Combo3", true);
        }
    }
    private IEnumerator ChargedAttack()
    {
        float startTime = Time.time;
        float endTime = 0f;

        isCharging = true;
        while (Mouse.current.rightButton.IsActuated())
        {
            endTime = Time.time;
            yield return null;
        }
        chargeTime = endTime - startTime;
        chargedDamage = damage * chargeTime;
        isCharging = false;
        anim.SetBool("HeavyCombo2", true);
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag("RatTeam"))
        {
            Health health = other.GetComponent<Health>();

            if (anim.GetCurrentAnimatorStateInfo(0).IsName("HeavyCombo2"))
            {
                health.TakingDamage(chargedDamage);
            }
            else if (anim.GetCurrentAnimatorStateInfo(0).IsName("Combo1") ||
                     anim.GetCurrentAnimatorStateInfo(0).IsName("Combo2") ||
                     anim.GetCurrentAnimatorStateInfo(0).IsName("Combo3"))
            {
                health.TakingDamage(damage);
            }
        }
    }
}
